#!/usr/bin/env node

/**
 * Cloud.gov rolling restage script
 *
 * Purpose:
 *   Restage apps in a single Cloud.gov space using the rolling strategy.
 *
 * Behavior:
 *   - Targets exactly one space per run
 *   - Dynamically discovers apps in that space
 *   - Restages apps sequentially, one app at a time
 *   - Verifies each app is healthy before moving to the next app
 *
 * Usage:
 *   node cf-restage.js <space> [--include <apps|all>] [--exclude <apps>]
 *   node cf-restage.js <space> --status
 *
 * Notes:
 *   - If neither --include nor --exclude is provided, all discovered apps are restaged.
 *   - --include and --exclude are optional filters.
 *   - --status cannot be combined with --include or --exclude.
 *
 * Examples:
 *   node cf-restage.js dev --status
 *   node cf-restage.js dev
 *   node cf-restage.js dev --include all
 *   node cf-restage.js dev --include auth-api,emissions-api
 *   node cf-restage.js dev --exclude quartz-scheduler
 *
 * Rollback:
 *   There is no true rollback for a restage. If an app fails:
 *   1. Check recent logs: cf logs <app-name> --recent
 *   2. Restage or restart the app manually after fixing the issue
 *   3. Do not proceed to the next space until the failed app is healthy
 */

const { execFileSync } = require('child_process');
const readline = require('readline');

const ORG = 'epa-easey';
const VALID_SPACES = ['dev', 'test', 'perf', 'staging', 'beta', 'prod'];
const APP_HEALTH_TIMEOUT_MS = 10 * 60 * 1000;
const APP_HEALTH_POLL_INTERVAL_MS = 10000;

const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const RESET = '\x1b[0m';

function info(msg) {
  console.log(CYAN + msg + RESET);
}

function success(msg) {
  console.log(GREEN + msg + RESET);
}

function error(msg) {
  console.error(RED + msg + RESET);
}

function warn(msg) {
  console.warn(YELLOW + msg + RESET);
}

function usage(exitCode = 0) {
  console.log('Usage: node cf-restage.js <space> [--include <apps|all>] [--exclude <apps>]');
  console.log('       node cf-restage.js <space> --status');
  console.log();
  console.log('  space                        One of: ' + VALID_SPACES.join(', '));
  console.log();
  console.log('Options:');
  console.log('  --include <apps|all>         Restage only the listed apps (comma-separated), or "all"');
  console.log('  --exclude <apps>             Restage all discovered apps except the listed ones (comma-separated)');
  console.log('  --status                     Check and display app statuses for the given space');
  console.log();
  console.log('Notes:');
  console.log('  - If no --include or --exclude is provided, all discovered apps are restaged.');
  console.log('  - --status cannot be combined with --include or --exclude.');
  console.log('  - Apps are restaged one at a time using: cf restage <app> --strategy rolling');
  console.log('  - Each app is verified as healthy before the script proceeds to the next app.');
  console.log();
  console.log('Examples:');
  console.log('  node cf-restage.js dev --status');
  console.log('  node cf-restage.js dev');
  console.log('  node cf-restage.js dev --include auth-api,emissions-api');
  console.log('  node cf-restage.js dev --include all');
  console.log('  node cf-restage.js dev --exclude quartz-scheduler');
  process.exit(exitCode);
}

function runCf(args, inherit = false) {
  const result = execFileSync('cf', args, {
    encoding: 'utf8',
    stdio: inherit ? 'inherit' : 'pipe',
  });

  return result ? result.trim() : '';
}

function runCfJson(args) {
  const output = runCf(args, false);
  try {
    return JSON.parse(output);
  } catch (e) {
    throw new Error('Failed to parse JSON from command: cf ' + args.join(' '));
  }
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function confirmProdAction({ space, statusOnly, mode, appList }) {
  return new Promise((resolve) => {
    warn('');
    warn('  *** WARNING: You are about to perform an action on PROD ***');
    warn('');
    warn('  Space:   ' + space);
    warn('  Action:  restage');

    if (mode === 'include') {
      warn('  Include: ' + appList.join(', '));
    } else if (mode === 'exclude') {
      warn('  Exclude: ' + appList.join(', '));
    } else {
      warn('  Apps:    all');
    }

    warn('');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    rl.question(YELLOW + '  Proceed? (y/N): ' + RESET, (answer) => {
      rl.close();
      resolve(answer.trim().toLowerCase() === 'y');
    });
  });
}

function ensureLoggedIn() {
  info('==> Validating Cloud Foundry session...');
  try {
    runCf(['oauth-token']);
  } catch (e) {
    throw new Error('Not logged in to cf. Run "cf login" first.');
  }
}

function targetSpace(space) {
  info("==> Targeting org '" + ORG + "' space '" + space + "'...");
  runCf(['target', '-o', ORG, '-s', space], true);
}

function getOrgGuid(org) {
  const response = runCfJson(['curl', '/v3/organizations?names=' + encodeURIComponent(org)]);
  const guid = response?.resources?.[0]?.guid;
  if (!guid) {
    throw new Error("Could not find org '" + org + "'.");
  }
  return guid;
}

function getSpaceGuid(orgGuid, space) {
  const response = runCfJson([
    'curl',
    '/v3/spaces?organization_guids=' + encodeURIComponent(orgGuid) + '&names=' + encodeURIComponent(space),
  ]);
  const guid = response?.resources?.[0]?.guid;
  if (!guid) {
    throw new Error("Could not find space '" + space + "' in org '" + ORG + "'.");
  }
  return guid;
}

function discoverApps(spaceGuid) {
  const response = runCfJson(['curl', '/v3/apps?space_guids=' + encodeURIComponent(spaceGuid) + '&per_page=5000']);
  const resources = response?.resources || [];

  return resources.map((app) => ({
    name: app.name,
    guid: app.guid,
    state: String(app.state || '').toLowerCase(),
  }));
}

function getProcesses(appGuid) {
  const response = runCfJson(['curl', '/v3/apps/' + encodeURIComponent(appGuid) + '/processes']);
  return response?.resources || [];
}

function getProcessStats(processGuid) {
  const response = runCfJson(['curl', '/v3/processes/' + encodeURIComponent(processGuid) + '/stats']);
  return response?.resources || [];
}

function parseAppList(args, startIndex) {
  const tokens = [];
  let i = startIndex;

  while (i + 1 < args.length && !args[i + 1].startsWith('--')) {
    i += 1;
    tokens.push(args[i]);
  }

  const names = tokens
    .join(',')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  return { names, nextIndex: i };
}

function parseArgs(argv) {
  if (argv.length === 0 || argv.includes('--help') || argv.includes('-h')) {
    usage(0);
  }

  const space = argv[0];
  if (!space || !VALID_SPACES.includes(space)) {
    throw new Error("Invalid space '" + (space || '') + "'. Must be one of: " + VALID_SPACES.join(', '));
  }

  let statusOnly = false;
  let mode = null;
  let appList = [];

  for (let i = 1; i < argv.length; i += 1) {
    const token = argv[i];

    if (token === '--status') {
      statusOnly = true;
      continue;
    }

    if (token === '--include') {
      if (mode !== null) {
        throw new Error('Only one of --include or --exclude can be specified.');
      }

      const result = parseAppList(argv, i);
      i = result.nextIndex;

      if (result.names.length === 0) {
        throw new Error('--include requires at least one app name or "all".');
      }

      if (result.names.includes('all')) {
        if (result.names.length > 1) {
          throw new Error('"all" cannot be mixed with specific app names in --include.');
        }
        mode = 'all';
      } else {
        mode = 'include';
        appList = result.names;
      }
      continue;
    }

    if (token === '--exclude') {
      if (mode !== null) {
        throw new Error('Only one of --include or --exclude can be specified.');
      }

      const result = parseAppList(argv, i);
      i = result.nextIndex;

      if (result.names.length === 0) {
        throw new Error('--exclude requires at least one app name.');
      }

      if (result.names.includes('all')) {
        throw new Error('"all" cannot be passed to --exclude.');
      }

      mode = 'exclude';
      appList = result.names;
      continue;
    }

    throw new Error("Unknown option '" + token + "'.");
  }

  if (statusOnly && mode !== null) {
    throw new Error('--status cannot be combined with --include or --exclude.');
  }

  if (!statusOnly && mode === null) {
    mode = 'all';
  }

  return { space, statusOnly, mode, appList };
}

function showStatus(spaceGuid, space) {
  const apps = discoverApps(spaceGuid).sort((a, b) => a.name.localeCompare(b.name));

  info("==> App statuses in '" + space + "':");
  if (apps.length === 0) {
    warn('No apps found in the targeted space.');
    return;
  }

  for (const app of apps) {
    console.log('  - ' + app.name + ': ' + app.state);
  }
}

function resolveAppsToRestage(discoveredApps, mode, appList) {
  const discoveredNames = discoveredApps.map((app) => app.name);
  let selectedApps = [];

  if (mode === 'all') {
    selectedApps = discoveredApps;
  } else if (mode === 'include') {
    const unmatched = appList.filter((name) => !discoveredNames.includes(name));
    if (unmatched.length > 0) {
      throw new Error('The following --include app names were not found: ' + unmatched.join(', '));
    }

    selectedApps = appList.map((name) => discoveredApps.find((app) => app.name === name));
  } else if (mode === 'exclude') {
    const unmatched = appList.filter((name) => !discoveredNames.includes(name));
    if (unmatched.length > 0) {
      warn('Warning: the following --exclude app names were not found in the space: ' + unmatched.join(', '));
    }

    selectedApps = discoveredApps.filter((app) => !appList.includes(app.name));
    info('==> Excluded ' + (discoveredApps.length - selectedApps.length) + ' app(s): ' + appList.join(', '));
  }

  if (selectedApps.length === 0) {
    throw new Error('No apps remaining to restage after filtering.');
  }

  return selectedApps;
}

function validateAppsForRestage(apps) {
  const nonStartedApps = apps.filter((app) => app.state !== 'started');
  if (nonStartedApps.length > 0) {
    warn(
      'Skipping non-started apps: ' +
      nonStartedApps.map((app) => app.name + ' (' + app.state + ')').join(', ')
    );
  }

  const startedApps = apps.filter((app) => app.state === 'started');
  if (startedApps.length === 0) {
    throw new Error('No started apps are eligible for restage.');
  }

  return startedApps;
}

function isWebProcessHealthy(stats) {
  if (!Array.isArray(stats) || stats.length === 0) {
    return false;
  }

  return stats.every((instance) => {
    const usage = instance?.usage || {};
    const state = String(instance?.state || '').toUpperCase();
    return state === 'RUNNING' && typeof usage === 'object';
  });
}

async function waitForAppHealthy(app, timeoutMs) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const processes = getProcesses(app.guid);
    const webProcess = processes.find((process) => process.type === 'web');

    if (!webProcess) {
      throw new Error("App '" + app.name + "' does not have a web process to verify.");
    }

    const stats = getProcessStats(webProcess.guid);
    if (isWebProcessHealthy(stats)) {
      success("    '" + app.name + "' is healthy.");
      return;
    }

    info("    Waiting for '" + app.name + "' to become healthy...");
    await delay(APP_HEALTH_POLL_INTERVAL_MS);
  }

  throw new Error("Timed out waiting for app '" + app.name + "' to become healthy.");
}

async function restageAppsSequentially(apps) {
  const failed = [];

  for (const app of apps) {
    info("=== Restaging '" + app.name + "'...");
    try {
      runCf(['restage', app.name, '--strategy', 'rolling'], true);
      await waitForAppHealthy(app, APP_HEALTH_TIMEOUT_MS);
      success("    '" + app.name + "' restaged successfully.");
    } catch (e) {
      error("    ERROR: '" + app.name + "' failed to restage or become healthy.");
      error('    ' + e.message);
      failed.push(app.name);
      break;
    }
    console.log();
  }

  if (failed.length > 0) {
    throw new Error(
      'FAILED apps: ' + failed.join(', ') + '. Check logs with: cf logs <app-name> --recent'
    );
  }
}

async function main() {
  try {
    const { space, statusOnly, mode, appList } = parseArgs(process.argv.slice(2));

    if (space === 'prod' && !statusOnly) {
      const confirmed = await confirmProdAction({ space, statusOnly, mode, appList });

      if (!confirmed) {
        warn('Aborted by user.');
        process.exit(0);
      }
    }

    ensureLoggedIn();
    targetSpace(space);

    const orgGuid = getOrgGuid(ORG);
    const spaceGuid = getSpaceGuid(orgGuid, space);

    if (statusOnly) {
      showStatus(spaceGuid, space);
      return;
    }

    info("==> Discovering apps in '" + space + "'...");
    const discoveredApps = discoverApps(spaceGuid);

    if (discoveredApps.length === 0) {
      throw new Error("No apps found in space '" + space + "'.");
    }

    const selectedApps = resolveAppsToRestage(discoveredApps, mode, appList);
    const appsToRestage = validateAppsForRestage(selectedApps);

    info('==> Apps to restage: ' + appsToRestage.map((app) => app.name).join(', '));
    console.log();

    await restageAppsSequentially(appsToRestage);

    console.log();
    info("==> Final app statuses in '" + space + "':");
    showStatus(spaceGuid, space);
    console.log();
    success("==> All selected apps restaged successfully in '" + space + "'.");
    warn('Proceed to the next space only after confirming expected application behavior.');
  } catch (e) {
    error('Error: ' + e.message);
    process.exit(1);
  }
}

main();
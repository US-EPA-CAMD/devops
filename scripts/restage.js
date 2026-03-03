#!/usr/bin/env node

// This script restages cloud.gov apps using a rolling strategy.

// Usage:
//   node restage.js <space> --status
//   node restage.js <space> --include <apps|all>
//   node restage.js <space> --exclude <apps>
//
// Examples:
//   node restage.js dev --status                           # check app statuses (started, etc)
//   node restage.js dev --include all                      # restage all apps in the dev space
//   node restage.js dev --include auth-api, emissions-api  # restage specific apps
//   node restage.js dev --exclude quartz-scheduler         # restage all except quartz-scheduler

const { execSync } = require('child_process');

const ORG = 'epa-easey';
const VALID_SPACES = ['dev', 'test', 'perf', 'staging', 'beta', 'prod'];

//color code console output to differentiate them against app restart logs.
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const RESET = '\x1b[0m';

function info(msg) {
  console.log(CYAN + msg + RESET);
}

function error(msg) {
  console.error(RED + msg + RESET);
}

function warn(msg) {
  console.error(YELLOW + msg + RESET);
}

function usage() {
  console.log('Usage: node restage.js <space> <--include <apps|all> | --exclude <apps>>');
  console.log('       node restage.js <space> --status');
  console.log();
  console.log('  space                        One of: ' + VALID_SPACES.join(', '));
  console.log();
  console.log('Options:');
  console.log('  --include <apps|all>         Restage only the listed apps (comma-separated), or "all"');
  console.log('  --exclude <apps>             Restage all discovered apps except the listed ones (comma-separated)');
  console.log('  --status                     Check and display app statuses for the given space');
  console.log();
  console.log('One of --include or --exclude is required when restaging.');
  console.log();
  console.log('Examples:');
  console.log('  node restage.js dev --status                            # check app statuses in dev');
  console.log('  node restage.js dev --include auth-api, emissions-api   # restage only these apps');
  console.log('  node restage.js dev --include all                       # restage all apps');
  console.log('  node restage.js dev --exclude auth-api, emissions-api   # restage all except these apps');
  process.exit(0);
}

function run(cmd) {
  return execSync(cmd, { encoding: 'utf-8', stdio: 'pipe' }).trim();
}

function runLive(cmd) {
  execSync(cmd, { stdio: 'inherit' });
}

function discoverApps() {
  const output = run('cf apps');
  const lines = output.split('\n');
  const headerIndex = lines.findIndex((line) => line.startsWith('name'));
  if (headerIndex === -1) return [];

  return lines
    .slice(headerIndex + 1)
    .map((line) => line.trim().split(/\s+/)[0])
    .filter((name) => name && name.length > 0);
}

// Handles: "auth-api, emissions-api" and "auth-api,emissions-api" and "auth-api , emissions-api"
function parseAppList(args, startIndex) {
  const tokens = [];
  let i = startIndex;
  while (i + 1 < args.length && args[i + 1].indexOf('--') !== 0) {
    i++;
    tokens.push(args[i]);
  }
  const names = tokens
    .join(',')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  return { names: names, nextIndex: i };
}

// Return app names not found in the discovered list, and warn about them
function warnUnmatched(flag, names, discovered) {
  const unmatched = names.filter((name) => discovered.indexOf(name) === -1);
  if (unmatched.length > 0) {
    warn('Warning: the following ' + flag + ' names were not found in the space: ' + unmatched.join(', '));
  }
  return unmatched;
}

// Parse arguments. space is always the first positional argument
const args = process.argv.slice(2);
if (args.length === 0) usage();

const space = args[0];
if (space === '--help' || space === '-h') usage();

if (VALID_SPACES.indexOf(space) === -1) {
  error("Error: Invalid space '" + space + "'. Must be one of: " + VALID_SPACES.join(', '));
  process.exit(1);
}

let statusOnly = false;
let mode = null;   // 'all', 'include', or 'exclude'
let appList = [];  // app names for 'include' or 'exclude' mode

for (let i = 1; i < args.length; i++) {
  if (args[i] === '--status') {
    statusOnly = true;
  } else if (args[i] === '--include') {
    if (mode !== null) {
      error('Error: Only one of --include or --exclude can be specified.');
      process.exit(1);
    }
    const result = parseAppList(args, i);
    i = result.nextIndex;
    if (result.names.length === 0) {
      error('Error: --include requires at least one app name or "all".');
      process.exit(1);
    }
    if (result.names.indexOf('all') !== -1) {
      if (result.names.length > 1) {
        error('Error: "all" cannot be mixed with specific app names in --include.');
        process.exit(1);
      }
      mode = 'all';
    } else {
      mode = 'include';
      appList = result.names;
    }
  } else if (args[i] === '--exclude') {
    if (mode !== null) {
      error('Error: Only one of --include or --exclude can be specified.');
      process.exit(1);
    }
    const result = parseAppList(args, i);
    i = result.nextIndex;
    if (result.names.length === 0) {
      error('Error: --exclude requires at least one app name.');
      process.exit(1);
    }
    if (result.names.indexOf('all') !== -1) {
      error('Error: "all" cannot be passed to --exclude (no apps would be restaged).');
      process.exit(1);
    }
    mode = 'exclude';
    appList = result.names;
  } else {
    error("Error: Unknown option '" + args[i] + "'.");
    process.exit(1);
  }
}

// Require --include or --exclude when restaging (not needed for --status)
if (!statusOnly && mode === null) {
  error('Error: One of --include or --exclude is required.');
  error('  Use --include all to restage every app in the space.');
  error('  Run with --help for usage details.');
  process.exit(1);
}

// Perform the requested action(restage, status, etc)

// Target the space
info("==> Targeting org '" + ORG + "' space '" + space + "'...");
try {
  runLive('cf target -o ' + ORG + ' -s ' + space);
} catch (e) {
  error("Error: Failed to target org '" + ORG + "' space '" + space + "'. Are you logged in? (cf login)");
  process.exit(1);
}

// --status: just show app statuses and exit
if (statusOnly) {
  info("==> App statuses in '" + space + "':");
  try {
    runLive('cf apps');
  } catch (e) {
    error('Error: Failed to retrieve app statuses.');
    process.exit(1);
  }
  process.exit(0);
}

// Discover all apps in the space
info("==> Discovering apps in '" + space + "'...");
let discovered;
try {
  discovered = discoverApps();
} catch (e) {
  error("Error: Failed to discover apps in space '" + space + "'.");
  process.exit(1);
}
if (discovered.length === 0) {
  error("Error: No apps found in space '" + space + "'.");
  process.exit(1);
}

// Resolve the final app list based on mode
let apps;

if (mode === 'all') {
  apps = discovered;
} else if (mode === 'include') {
  const unmatched = warnUnmatched('--include', appList, discovered);
  apps = appList.filter((name) => unmatched.indexOf(name) === -1);
} else {
  apps = discovered.filter((app) => appList.indexOf(app) === -1);
  info('==> Excluded ' + (discovered.length - apps.length) + ' app(s): ' + appList.join(', '));
  warnUnmatched('--exclude', appList, discovered);
}

if (apps.length === 0) {
  error('Error: No apps remaining to restage after filtering.');
  process.exit(1);
}

info('==> Apps to restage: ' + apps.join(', ') + '\n');

// Restage each app
const failed = [];
for (let i = 0; i < apps.length; i++) {
  const app = apps[i];
  info("=== Restaging '" + app + "'...");
  try {
    runLive('cf restage ' + app + ' --strategy rolling');
    info("    '" + app + "' restaged successfully.");
  } catch (e) {
    error("    ERROR: '" + app + "' failed to restage.");
    failed.push(app);
  }
  console.log();
}

// Verify status
info("==> Verifying app status in '" + space + "'...");
try {
  runLive('cf apps');
} catch (e) {
  warn('Warning: Failed to verify app statuses. Check manually with: cf apps');
}
console.log();

// Summary
if (failed.length > 0) {
  error('==> FAILED apps: ' + failed.join(', '));
  error('    Check logs with: cf logs <app-name> --recent');
  process.exit(1);
} else {
  info("==> All apps restaged successfully in '" + space + "'.");
  console.warn('    You must perform manual health checks on all restaged apps before proceeding to the next space.');
}

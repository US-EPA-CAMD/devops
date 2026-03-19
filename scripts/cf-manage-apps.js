#!/usr/bin/env node

/**
 * Cloud.gov environment scaler
 *
 * Purpose:
 *   Scale an environment up for testing or down when idle.
 *
 * Supported actions:
 *   - up       : upgrade DB plan, then start all apps
 *   *            requires --plan
 *   - down     : stop all apps, then downgrade DB plan
 *   *            requires --plan
 *   - start    : start all apps only
 *   - stop     : stop all apps only
 *   - update-db: change DB plan only
 *   *            requires --plan
 *   - status   : show app + DB status
 *
 * Optional app filter:
 *   - --apps <app1,app2,...>
 *   * limits app start/stop operations to only the listed apps
 *   * applies to: up, down, start, stop
 *   * does not affect update-db or status
 *
 * Security:
 *   - Uses the existing cf CLI login session.
 *   - Does not accept usernames/passwords on the command line.
 *   - Uses execFileSync with argument arrays to avoid shell injection.
 *
 * Setup:
 *   1. Install cf CLI v8+
 *   2. Log in: cf login
 *   3. Ensure you have access to the target org/space and service instance
 *   4. Run this script
 *
 * Examples:
 *   node cf-manage-apps.js perf up --plan large-gp-psql-replica
 *   node cf-manage-apps.js perf down --plan medium-gp-psql-replica
 *   node cf-manage-apps.js perf start
 *   node cf-manage-apps.js perf stop
 *   node cf-manage-apps.js perf update-db --plan large-gp-psql-replica
 *   node cf-manage-apps.js perf status
 *   node cf-manage-apps.js perf start --apps auth-api, camd-services
 *   node cf-manage-apps.js perf stop --apps auth-api
 *   node cf-manage-apps.js perf up --plan large-gp-psql-replica --apps auth-api
 *   node cf-manage-apps.js perf down --plan medium-gp-psql-replica --apps auth-api
 *
 *   Run ' cf marketplace -e aws-rds | grep psql' to discover available database plans to up/down to
 *
 * Rollback:
 *   - Roll back "up" with:   node cf-manage-apps.js <space> down --plan <previous-plan>
 *   - Roll back "down" with: node cf-manage-apps.js <space> up --plan <previous-plan>
 *   - Roll back a DB change: node cf-manage-apps.js <space> update-db --plan <previous-plan>
 */

const { execFileSync } = require('child_process');
const readline = require('readline');

const CONFIG = {
  org: 'epa-easey',
  spaces: {
    dev: { dbServiceName: 'camd-pg-db' },
    test: { dbServiceName: 'camd-pg-db' },
    perf: { dbServiceName: 'camd-pg-db' },
    staging: { dbServiceName: 'camd-pg-db' },
    beta: { dbServiceName: 'camd-pg-db' },
    prod: { dbServiceName: 'camd-pg-db' },
  },
  pollIntervalMs: 15000,
  dbUpdateTimeoutMs: 30 * 60 * 1000,
};

const VALID_ACTIONS = new Set(['up', 'down', 'start', 'stop', 'update-db', 'status']);

const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const RESET = '\x1b[0m';

function info(message) {
  console.log(`${CYAN}${message}${RESET}`);
}

function success(message) {
  console.log(`${GREEN}${message}${RESET}`);
}

function warn(message) {
  console.warn(`${YELLOW}${message}${RESET}`);
}

function fail(message) {
  console.error(`${RED}${message}${RESET}`);
}

function usage(exitCode = 0) {
  const spaces = Object.keys(CONFIG.spaces).join(', ');

  console.log('Usage:');
  console.log('  node cf-manage-apps.js <space> <action> [options]');
  console.log('');
  console.log('Spaces:');
  console.log(`  ${spaces}`);
  console.log('');
  console.log('Actions:');
  console.log('  up                       Upgrade DB plan, then start all apps (requires --plan)');
  console.log('  down                     Stop all apps, then downgrade DB plan (requires --plan)');
  console.log('  start                    Start all apps only');
  console.log('  stop                     Stop all apps only');
  console.log('  update-db                Update DB plan only (requires --plan)');
  console.log('  status                   Show app and DB status');
  console.log('');
  console.log('Options:');
  console.log('  --plan <plan>            Required for up, down, and update-db');
  console.log('  --apps <app1,app2,...>   Limit app start/stop operations to selected apps');
  console.log('                           Valid with: up, down, start, stop');
  console.log('  -h, --help               Show help');
  console.log('');
  console.log('Examples:');
  console.log('  node cf-manage-apps.js perf up --plan large-gp-psql-replica');
  console.log('  node cf-manage-apps.js perf down --plan medium-gp-psql-replica');
  console.log('  node cf-manage-apps.js perf start');
  console.log('  node cf-manage-apps.js perf stop');
  console.log('  node cf-manage-apps.js perf update-db --plan large-gp-psql-replica');
  console.log('  node cf-manage-apps.js perf status');
  console.log('  node cf-manage-apps.js perf start --apps auth-api,camd-services');
  console.log('  node cf-manage-apps.js perf stop --apps auth-api');
  console.log('  node cf-manage-apps.js perf up --plan large-gp-psql-replica --apps auth-api,camd-services');
  console.log('');
  console.log('Behavior of --apps:');
  console.log('  - Only the listed apps are started/stopped');
  console.log('  - DB updates still run normally for up/down/update-db');
  console.log('  - Unrecognized app names are reported as errors');
  console.log('');
  console.log('Rollback:');
  console.log('  node cf-manage-apps.js <space> down --plan <previous-plan>');
  console.log('  node cf-manage-apps.js <space> up --plan <previous-plan>');
  console.log('  node cf-manage-apps.js <space> update-db --plan <previous-plan>');
  process.exit(exitCode);
}

function parseAppsList(value) {
  if (!value) {
    throw new Error('--apps requires a comma-separated list of app names.');
  }

  const apps = value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

  if (apps.length === 0) {
    throw new Error('--apps requires at least one app name.');
  }

  return [...new Set(apps)];
}

function parseArgs(argv) {
  if (argv.length === 0 || argv.includes('-h') || argv.includes('--help')) {
    usage(0);
  }

  const [space, action, ...rest] = argv;

  if (!space || !CONFIG.spaces[space]) {
    throw new Error(
      `Invalid or missing space '${space || ''}'. Valid spaces: ${Object.keys(CONFIG.spaces).join(', ')}`
    );
  }

  if (!action || !VALID_ACTIONS.has(action)) {
    throw new Error(
      `Invalid or missing action '${action || ''}'. Valid actions: ${Array.from(VALID_ACTIONS).join(', ')}`
    );
  }

  let plan = null;
  let testApps = null;

  for (let i = 0; i < rest.length; i += 1) {
    const token = rest[i];

    if (token === '--plan') {
      plan = rest[i + 1];
      i += 1;

      if (!plan) {
        throw new Error('--plan requires a value.');
      }
      continue;
    }

    if (token === '--apps') {
      testApps = parseAppsList(rest[i + 1]);
      i += 1;
      continue;
    }

    throw new Error(`Unknown option '${token}'.`);
  }

  if ((action === 'up' || action === 'down' || action === 'update-db') && !plan) {
    throw new Error(`Action '${action}' requires --plan <plan>.`);
  }

  if ((action === 'start' || action === 'stop' || action === 'status') && plan) {
    throw new Error(`--plan is not valid with the '${action}' action.`);
  }

  if ((action === 'update-db' || action === 'status') && testApps) {
    throw new Error(`--apps is not valid with the '${action}' action.`);
  }

  return { space, action, plan, testApps };
}

function runCommand(command, args, options = {}) {
  const stdio = options.inherit ? 'inherit' : 'pipe';

  const result = execFileSync(command, args, {
    encoding: 'utf8',
    stdio,
  });

  return result ? result.trim() : '';
}

function runCf(args, options = {}) {
  return runCommand('cf', args, options);
}

function runCfJson(args, options = {}) {
  const output = runCf(args, options);

  try {
    return JSON.parse(output);
  } catch (error) {
    throw new Error(`Failed to parse JSON from: cf ${args.join(' ')}`);
  }
}

async function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function confirmProdAction({ space, action, plan, testApps }) {
  return new Promise((resolve) => {
    warn('');
    warn('  *** WARNING: You are about to perform an action on PROD ***');
    warn('');
    warn(`  Space:   ${space}`);
    warn(`  Action:  ${action}`);
    if (plan) {
      warn(`  Plan:    ${plan}`);
    }
    if (testApps && testApps.length > 0) {
      warn(`  Apps:    ${testApps.join(', ')}`);
    } else {
      warn('  Apps:    all');
    }
    warn('');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    rl.question(`${YELLOW}  Proceed? (y/N): ${RESET}`, (answer) => {
      rl.close();
      resolve(answer.trim().toLowerCase() === 'y');
    });
  });
}

function ensureLoggedIn() {
  info('==> Validating Cloud Foundry session...');
  try {
    runCf(['oauth-token']);
  } catch (error) {
    throw new Error('Not logged in to cf. Run "cf login" first.');
  }
}

function targetOrgAndSpace(org, space) {
  info(`==> Targeting org '${org}' / space '${space}'...`);
  runCf(['target', '-o', org, '-s', space], { inherit: true });
}

function getOrgGuid(org) {
  const response = runCfJson(['curl', `/v3/organizations?names=${encodeURIComponent(org)}`]);

  const guid = response?.resources?.[0]?.guid;
  if (!guid) {
    throw new Error(`Could not find org '${org}'.`);
  }

  return guid;
}

function getSpaceGuid(orgGuid, space) {
  const response = runCfJson([
    'curl',
    `/v3/spaces?organization_guids=${orgGuid}&names=${encodeURIComponent(space)}`,
  ]);

  const guid = response?.resources?.[0]?.guid;
  if (!guid) {
    throw new Error(`Could not find space '${space}' in org '${CONFIG.org}'.`);
  }

  return guid;
}

function listApps(spaceGuid) {
  const response = runCfJson(['curl', `/v3/apps?space_guids=${spaceGuid}&per_page=5000`]);

  const resources = response?.resources || [];
  return resources.map((app) => ({
    name: app.name,
    guid: app.guid,
    state: String(app.state || '').toLowerCase(),
  }));
}

function getServiceInstance(spaceGuid, serviceName) {
  const response = runCfJson([
    'curl',
    `/v3/service_instances?space_guids=${spaceGuid}&names=${encodeURIComponent(serviceName)}&per_page=5000`,
  ]);

  const service = response?.resources?.[0];
  if (!service) {
    throw new Error(`Could not find service instance '${serviceName}' in the targeted space.`);
  }

  return service;
}

function getServicePlanName(servicePlanGuid) {
  const response = runCfJson(['curl', `/v3/service_plans/${servicePlanGuid}`]);

  const name = response?.name;
  if (!name) {
    throw new Error(`Could not resolve service plan name for plan guid '${servicePlanGuid}'.`);
  }

  return name;
}

function getDbState(spaceGuid, serviceName) {
  const service = getServiceInstance(spaceGuid, serviceName);
  const planGuid = service?.relationships?.service_plan?.data?.guid;

  if (!planGuid) {
    throw new Error(`Service instance '${serviceName}' does not expose a service_plan relationship.`);
  }

  const planName = getServicePlanName(planGuid);
  const operationState = service?.last_operation?.state || 'unknown';
  const operationDescription = service?.last_operation?.description || '';

  return {
    serviceGuid: service.guid,
    serviceName: service.name,
    planName,
    operationState,
    operationDescription,
  };
}

async function waitForDbUpdate(spaceGuid, serviceName, timeoutMs) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const state = getDbState(spaceGuid, serviceName);

    if (state.operationState === 'succeeded') {
      success(`==> DB update completed. Plan is now '${state.planName}'.`);
      return;
    }

    if (state.operationState === 'failed') {
      throw new Error(
        `Database update failed. Last operation: ${state.operationDescription || 'no description returned'}`
      );
    }

    info(
      `==> Waiting for DB update... state='${state.operationState}', detail='${state.operationDescription || 'n/a'}'`
    );
    await delay(CONFIG.pollIntervalMs);
  }

  throw new Error(`Timed out waiting for DB update after ${timeoutMs / 60000} minutes.`);
}

function partitionAppsByTargetState(apps, targetState) {
  const alreadyDone = [];
  const todo = [];

  for (const app of apps) {
    if (app.state === targetState) {
      alreadyDone.push(app);
    } else {
      todo.push(app);
    }
  }

  return { alreadyDone, todo };
}

function printAppSummary(label, apps) {
  if (apps.length === 0) {
    info(`    ${label}: none`);
    return;
  }

  info(`    ${label}: ${apps.map((app) => app.name).join(', ')}`);
}

function changeAppState(appName, action) {
  runCf([action, appName], { inherit: true });
}

function updateDbPlan(serviceName, currentPlan, targetPlan) {
  if (currentPlan === targetPlan) {
    info(`==> DB already on plan '${targetPlan}'. Nothing to do.`);
    return false;
  }

  info(`==> Updating DB plan: '${currentPlan}' -> '${targetPlan}'`);
  runCf(['update-service', serviceName, '-p', targetPlan], { inherit: true });
  return true;
}

function filterAppsForTestMode(apps, testApps) {
  if (!testApps || testApps.length === 0) {
    return apps;
  }

  const appMap = new Map(apps.map((app) => [app.name, app]));
  const missingApps = testApps.filter((name) => !appMap.has(name));

  if (missingApps.length > 0) {
    throw new Error(
      `The following app(s) were not found in the targeted space: ${missingApps.join(', ')}`
    );
  }

  return testApps.map((name) => appMap.get(name));
}

function showStatus(space) {
  const org = CONFIG.org;
  const { dbServiceName } = CONFIG.spaces[space];

  ensureLoggedIn();
  targetOrgAndSpace(org, space);

  const orgGuid = getOrgGuid(org);
  const spaceGuid = getSpaceGuid(orgGuid, space);
  const apps = listApps(spaceGuid);
  const db = getDbState(spaceGuid, dbServiceName);

  info(`==> Status for '${space}'`);
  console.log('');

  info('Apps:');
  if (apps.length === 0) {
    console.log('  No apps found.');
  } else {
    for (const app of apps.sort((a, b) => a.name.localeCompare(b.name))) {
      console.log(`  - ${app.name}: ${app.state}`);
    }
  }

  console.log('');
  info('Database:');
  console.log(`  - Service: ${db.serviceName}`);
  console.log(`  - Plan: ${db.planName}`);
  console.log(`  - Last operation state: ${db.operationState}`);
  if (db.operationDescription) {
    console.log(`  - Last operation detail: ${db.operationDescription}`);
  }
}

async function startOrStopApps(space, action, testApps = null) {
  const org = CONFIG.org;
  const targetState = action === 'start' ? 'started' : 'stopped';

  ensureLoggedIn();
  targetOrgAndSpace(org, space);

  const orgGuid = getOrgGuid(org);
  const spaceGuid = getSpaceGuid(orgGuid, space);
  const allApps = listApps(spaceGuid);

  info(`==> Discovering apps in '${space}'...`);

  if (allApps.length === 0) {
    warn('No apps found in the targeted space.');
    return;
  }

  const apps = filterAppsForTestMode(allApps, testApps);

  if (testApps && testApps.length > 0) {
    info(`==> Limiting app operations to: ${testApps.join(', ')}`);
  }

  const { alreadyDone, todo } = partitionAppsByTargetState(apps, targetState);

  printAppSummary(`Already ${targetState}`, alreadyDone);
  printAppSummary(`To ${action}`, todo);

  if (todo.length === 0) {
    info(`==> All selected apps are already ${targetState}. Nothing to do.`);
    return;
  }

  const failedApps = [];

  for (const app of todo) {
    info(`==> ${action === 'start' ? 'Starting' : 'Stopping'} '${app.name}'...`);
    try {
      changeAppState(app.name, action);
      success(`    '${app.name}' ${targetState}.`);
    } catch (error) {
      failedApps.push(app.name);
      fail(`    Failed to ${action} '${app.name}'.`);
    }
  }

  if (failedApps.length > 0) {
    throw new Error(
      `Some apps failed to ${action}: ${failedApps.join(', ')}. Check with "cf logs <app-name> --recent".`
    );
  }

  success(`==> Selected app operations completed successfully in '${space}'.`);
}

async function updateDb(space, targetPlan) {
  const org = CONFIG.org;
  const { dbServiceName } = CONFIG.spaces[space];

  ensureLoggedIn();
  targetOrgAndSpace(org, space);

  const orgGuid = getOrgGuid(org);
  const spaceGuid = getSpaceGuid(orgGuid, space);
  const currentDb = getDbState(spaceGuid, dbServiceName);

  const changed = updateDbPlan(dbServiceName, currentDb.planName, targetPlan);

  if (!changed) {
    return;
  }

  await waitForDbUpdate(spaceGuid, dbServiceName, CONFIG.dbUpdateTimeoutMs);
}

async function scaleUp(space, plan, testApps = null) {
  info(`==> Scaling '${space}' UP`);
  await updateDb(space, plan);
  await startOrStopApps(space, 'start', testApps);
  success(`==> '${space}' is scaled UP.`);
}

async function scaleDown(space, plan, testApps = null) {
  info(`==> Scaling '${space}' DOWN`);
  await startOrStopApps(space, 'stop', testApps);
  await updateDb(space, plan);
  success(`==> '${space}' is scaled DOWN.`);
}

async function main() {
  try {
    const { space, action, plan, testApps } = parseArgs(process.argv.slice(2));

    if (space === 'prod') {
      const confirmed = await confirmProdAction({ space, action, plan, testApps });

      if (!confirmed) {
        warn('Aborted by user.');
        process.exit(0);
      }
    }

    switch (action) {
      case 'up':
        await scaleUp(space, plan, testApps);
        break;
      case 'down':
        await scaleDown(space, plan, testApps);
        break;
      case 'start':
        await startOrStopApps(space, 'start', testApps);
        break;
      case 'stop':
        await startOrStopApps(space, 'stop', testApps);
        break;
      case 'update-db':
        await updateDb(space, plan);
        break;
      case 'status':
        showStatus(space);
        break;
      default:
        throw new Error(`Unsupported action '${action}'.`);
    }
  } catch (error) {
    fail(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
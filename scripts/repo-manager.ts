#!/usr/bin/env node

/**
 * Repository Update Script
 * ========================
 *
 * This script automates repository management tasks in parallel.
 *
 * REFRESH mode performs the following actions on each repository:
 * 1. Checks for uncommitted changes (ignores new/untracked files)
 * 2. Switches to specified branch (git checkout <branch>, defaults to develop)
 * 3. Pulls latest changes (git pull)
 * 4. Installs dependencies (yarn install) - SKIPPED for easey-quartz-scheduler
 * 5. Builds the project (yarn build) - SKIPPED for easey-quartz-scheduler
 * 6. Kills any existing process running on the app's port (reads from .env file) - SKIPPED for easey-quartz-scheduler
 *
 * TERMINATE mode performs only:
 * 1. Kills any existing process running on the app's port (reads from .env file)
 *
 * Prerequisites:
 * - Node.js and npm/yarn installed
 * - TypeScript and tsx installed globally: npm install -g typescript tsx
 * - All target repositories must be siblings of the devops repo
 * - Each repository should be a git repository with the target branch
 * - Each repository should have package.json with build and up scripts
 *
 * Repo root:
 * - Defaults to ../../ relative to this script (parent of devops repo)
 * - Override with EASEY_APPS_LOCAL_REPO_ROOT environment variable
 * - The script can be run from any directory
 *
 * How to run:
 *    Run from any directory. Examples assume you are in the devops repo.
 *
 * REFRESH MODE (full repository update):
 *    - All repositories:
 *          npx tsx scripts/repo-manager.ts refresh
 *    - Specific repositories:
 *          npx tsx scripts/repo-manager.ts refresh easey-camd-services easey-auth-api
 *    - Custom branch (defaults to develop):
 *          npx tsx scripts/repo-manager.ts refresh --branch release/v2.0
 *
 * TERMINATE MODE (terminate processes only):
 *    - All repositories:
 *          npx tsx scripts/repo-manager.ts terminate
 *    - Specific repositories (No confirmation prompts, directly kills processes on configured ports):
 *          npx tsx scripts/repo-manager.ts terminate easey-camd-services easey-auth-api
 *
 * Safety:
 * - Repositories with uncommitted changes are automatically skipped
 * - User confirmation required before proceeding
 * - Summary report showing success/failure status for each repo
 */

import { execSync, spawn } from 'child_process';
import * as readline from 'readline';
import * as path from 'path';
import * as fs from 'fs';

// Root directory where all easey-* repos are checked out.
// Resolves to ../../ relative to this script (i.e., the parent of the devops repo).
// Override by setting EASEY_APPS_LOCAL_REPO_ROOT environment variable.
const REPO_ROOT = process.env.EASEY_APPS_LOCAL_REPO_ROOT
  || path.resolve(__dirname, '..', '..');

// ANSI color codes
const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const DIM = '\x1b[2m';
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';

// Map repository names to their port configuration (either environment variable or static port)
const REPO_CONFIG: { [key: string]: { portEnvVar?: string; portValue?: number; enabled: boolean } } = {
  'easey-auth-api': { portEnvVar: 'EASEY_AUTH_API_PORT', enabled: true },
  'easey-monitor-plan-api': { portEnvVar: 'EASEY_MONITOR_PLAN_API_PORT', enabled: true },
  'easey-facilities-api': { portEnvVar: 'EASEY_FACILITIES_API_PORT', enabled: true },
  'easey-qa-certification-api': { portEnvVar: 'EASEY_QA_CERTIFICATION_API_PORT', enabled: true },
  'easey-emissions-api': { portEnvVar: 'EASEY_EMISSIONS_API_PORT', enabled: true },
  'easey-camd-services': { portEnvVar: 'EASEY_CAMD_SERVICES_PORT', enabled: true },
  'easey-streaming-services': { portEnvVar: 'EASEY_STREAMING_SERVICES_PORT', enabled: true },
  'easey-mdm-api': { portEnvVar: 'EASEY_MDM_API_PORT', enabled: true },
  'easey-account-api': { portEnvVar: 'EASEY_ACCOUNT_API_PORT', enabled: true },
  'easey-quartz-scheduler': { portValue: 0, enabled: true },
  'easey-ecmps-ui': { portValue: 3000, enabled: true },
  'easey-campd-ui': { portEnvVar: 'EASEY_CAMPD_UI_PORT', enabled: false }
};

// Extract the list of enabled repositories
const REPOSITORIES = Object.keys(REPO_CONFIG).filter(repo => REPO_CONFIG[repo].enabled);

interface RepoStatus {
  name: string;
  path: string;
  hasUncommittedChanges: boolean;
  status: 'pending' | 'processing' | 'success' | 'error';
  error?: string;
}

type CommandMode = 'refresh' | 'terminate';

class RepoUpdater {
  private repos: RepoStatus[] = [];
  private rl: readline.Interface;
  private targetRepos: string[];
  private mode: CommandMode;
  private branch: string;

  constructor(mode: CommandMode, targetRepos?: string[], branch?: string) {
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    this.mode = mode;
    this.branch = branch || 'develop';
    // Use provided repositories or default to all defined repositories
    this.targetRepos = targetRepos && targetRepos.length > 0 ? targetRepos : REPOSITORIES;
  }

  private async question(prompt: string): Promise<string> {
    return new Promise((resolve) => {
      this.rl.question(prompt, resolve);
    });
  }

  private checkUncommittedChanges(repoPath: string): boolean {
    try {
      // Check for uncommitted changes (staged + unstaged, ignore untracked files)
      const result = execSync('git diff --quiet HEAD', {
        cwd: repoPath,
        stdio: 'pipe'
      });
      return false; // No changes
    } catch (error) {
      return true; // Has changes
    }
  }

  private readEnvFile(repoPath: string): { [key: string]: string } {
    const envPath = path.join(repoPath, '.env');
    const env: { [key: string]: string } = {};

    if (!fs.existsSync(envPath)) {
      return env;
    }

    try {
      const envContent = fs.readFileSync(envPath, 'utf-8');
      const lines = envContent.split('\n');

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#')) {
          const [key, ...valueParts] = trimmed.split('=');
          if (key && valueParts.length > 0) {
            env[key.trim()] = valueParts.join('=').trim();
          }
        }
      }
    } catch (error) {
      console.log(`${YELLOW}   WARNING: Could not read .env file for ${path.basename(repoPath)}${RESET}`);
    }

    return env;
  }

  private async killProcessOnPort(port: string): Promise<void> {
    if (!port) return;

    try {
      // Find process using the port
      const findCommand = process.platform === 'win32'
        ? `netstat -ano | findstr :${port}`
        : `lsof -ti:${port}`;

      const result = execSync(findCommand, { stdio: 'pipe', encoding: 'utf-8' });

      if (result.trim()) {
        if (process.platform === 'win32') {
          // Windows: Extract PID and kill
          const lines = result.trim().split('\n');
          for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            const pid = parts[parts.length - 1];
            if (pid && /^\d+$/.test(pid)) {
              execSync(`taskkill /F /PID ${pid}`, { stdio: 'pipe' });
              console.log(`      Killed process ${pid}`);
            }
          }
        } else {
          // Unix/Linux/Mac: lsof returns PIDs directly
          const pids = result.trim().split('\n');
          for (const pid of pids) {
            if (pid && /^\d+$/.test(pid.trim())) {
              execSync(`kill -9 ${pid.trim()}`, { stdio: 'pipe' });
              console.log(`      Killed process ${pid.trim()}`);
            }
          }
        }
      }
    } catch (error) {
      // No process found on port or kill failed - this is usually fine
    }
  }

  private async initializeRepos(): Promise<void> {
    console.log('Checking repository status...');

    // Validate that specified repositories exist in the REPO_CONFIG
    if (this.targetRepos !== REPOSITORIES) {
      const invalidRepos = this.targetRepos.filter(repo => !Object.keys(REPO_CONFIG).includes(repo));
      if (invalidRepos.length > 0) {
        console.log(`\n${YELLOW}   WARNING: Invalid repositories will be skipped:${RESET}`);
        invalidRepos.forEach(repo => console.log(`      ${repo}`));
        console.log(`\n   Valid repositories: ${Object.keys(REPO_CONFIG).join(', ')}`);

        // Filter out invalid repositories
        this.targetRepos = this.targetRepos.filter(repo => Object.keys(REPO_CONFIG).includes(repo));

        if (this.targetRepos.length === 0) {
          console.log(`\n${RED}No valid repositories specified. Exiting.${RESET}`);
          return;
        }
      }
    }

    for (const repoName of this.targetRepos) {
      const repoPath = path.join(REPO_ROOT, repoName);

      if (!fs.existsSync(repoPath)) {
        console.log(`${YELLOW}   ${repoName.padEnd(25)}   Not found, skipping${RESET}`);
        continue;
      }

      if (!fs.existsSync(path.join(repoPath, '.git'))) {
        console.log(`${YELLOW}   ${repoName.padEnd(25)}   Not a git repository, skipping${RESET}`);
        continue;
      }

      // Only check for uncommitted changes in refresh mode
      const hasChanges = this.mode === 'refresh' ? this.checkUncommittedChanges(repoPath) : false;

      this.repos.push({
        name: repoName,
        path: repoPath,
        hasUncommittedChanges: hasChanges,
        status: 'pending'
      });

      if (this.mode === 'refresh') {
        const status = hasChanges
          ? `${RED}Has uncommitted changes${RESET}`
          : `${GREEN}Clean${RESET}`;
        console.log(`   ${repoName.padEnd(25)}   ${status}`);
      } else {
        console.log(`   ${repoName.padEnd(25)}   Ready for process termination`);
      }
    }
  }

  private async confirmPreconditions(): Promise<boolean> {
    if (this.mode === 'terminate') {
      // Terminate mode: no confirmations needed, process all repos
      console.log('Repositories to process:');
      this.repos.forEach(repo => console.log(`   ${repo.name.padEnd(25)}   Terminate processes`));
      return true;
    }

    // Refresh mode: check for uncommitted changes and get confirmations
    const reposWithChanges = this.repos.filter(r => r.hasUncommittedChanges);
    const reposToUpdate = this.repos.filter(r => !r.hasUncommittedChanges);

    if (reposWithChanges.length > 0) {
      console.log(`${YELLOW}Repositories with uncommitted changes (will be skipped):${RESET}`);
      reposWithChanges.forEach(repo => console.log(`${YELLOW}   ${repo.name.padEnd(25)}   Skipped${RESET}`));
      console.log('');
    }

    if (reposToUpdate.length > 0) {
      console.log('Repositories to update:');
      reposToUpdate.forEach(repo => console.log(`${GREEN}   ${repo.name.padEnd(25)}   Ready${RESET}`));
    }

    if (reposToUpdate.length === 0) {
      console.log(`${RED}No repositories are ready for update. Exiting.${RESET}`);
      return false;
    }

    const confirmChanges = await this.question('\nConfirm you have committed or stashed all important changes? (y/N): ');
    if (confirmChanges.toLowerCase() !== 'y' && confirmChanges.toLowerCase() !== 'yes') {
      console.log(`${RED}Aborted by user.${RESET}`);
      return false;
    }

    return true;
  }

  private async updateRepo(repo: RepoStatus): Promise<void> {
    console.log(`\n${BOLD}${repo.name}${RESET}`);
    console.log(`${'='.repeat(30)}`);
    repo.status = 'processing';

    if (this.mode === 'terminate') {
      // Terminate mode: only kill existing processes
      await this.killExistingProcess(repo);
      repo.status = 'success';
      console.log(`${GREEN}   Completed${RESET}`);
      return;
    }

    // Refresh mode: run update sequence
    // For easey-quartz-scheduler, skip steps 4 (yarn install), 5 (yarn build), and 6 (kill app)
    const isQuartzScheduler = repo.name === 'easey-quartz-scheduler';

    const commands = [
      `git checkout ${this.branch}`,
      'git pull'
    ];

    // Add yarn install and build commands for non-quartz-scheduler projects
    if (!isQuartzScheduler) {
      commands.push('yarn install', 'yarn build');
    }

    try {
      for (const command of commands) {
        await this.runCommand(repo, command);
      }

      // Skip killing process for easey-quartz-scheduler (step 6)
      if (!isQuartzScheduler) {
        await this.killExistingProcess(repo);
      }

      repo.status = 'success';
      console.log(`${GREEN}   All tasks completed successfully${RESET}`);
    } catch (error) {
      // Error already logged in runCommand
      repo.status = 'error';
    }
  }

  private async runCommand(repo: RepoStatus, command: string): Promise<void> {
    return new Promise((resolve, reject) => {
      console.log(`${DIM}   ${command.padEnd(20)}   Running...${RESET}`);

      const [cmd, ...args] = command.split(' ');
      const process = spawn(cmd, args, {
        cwd: repo.path,
        stdio: 'pipe',
        shell: true  // This ensures PATH is properly resolved
      });

      let output = '';
      let errorOutput = '';

      process.stdout?.on('data', (data) => {
        output += data.toString();
      });

      process.stderr?.on('data', (data) => {
        errorOutput += data.toString();
      });

      process.on('close', (code) => {
        if (code === 0) {
          console.log(`${GREEN}   ${command.padEnd(20)}   Done${RESET}`);
          resolve();
        } else {
          repo.error = `Command "${command}" failed with code ${code}:\n${errorOutput}`;
          console.log(`${RED}   ${command.padEnd(20)}   Failed${RESET}`);
          console.log(`${RED}      Error: ${errorOutput.split('\n')[0].trim()}${RESET}`);
          reject(new Error(repo.error));
        }
      });
    });
  }

  private async killExistingProcess(repo: RepoStatus): Promise<void> {
    const repoConfig = REPO_CONFIG[repo.name];
    if (!repoConfig) return;

    let port: string | undefined;

    // Check if we have a static port value
    if (repoConfig.portValue) {
      port = repoConfig.portValue.toString();
    } else if (repoConfig.portEnvVar) {
      // Read the .env file to get the port
      const env = this.readEnvFile(repo.path);
      port = env[repoConfig.portEnvVar];
    }

    if (port) {
      console.log(`${DIM}   ${'Kill processes'.padEnd(20)}   Checking port ${port}...${RESET}`);
      await this.killProcessOnPort(port);
      console.log(`${GREEN}   ${'Kill processes'.padEnd(20)}   Done${RESET}`);
    } else {
      console.log(`${YELLOW}   ${'Kill processes'.padEnd(20)}   No port found${RESET}`);
    }
  }

  private async updateReposInParallel(): Promise<void> {
    const reposToProcess = this.mode === 'terminate'
      ? this.repos  // Terminate mode: process all repos regardless of uncommitted changes
      : this.repos.filter(r => !r.hasUncommittedChanges);  // Refresh mode: skip repos with changes

    const actionWord = this.mode === 'terminate' ? 'termination of' : 'refresh of';
    console.log(`\nStarting ${actionWord} ${reposToProcess.length} repositories...`);

    // Process repositories sequentially for clearer output
    for (const repo of reposToProcess) {
      try {
        await this.updateRepo(repo);
      } catch (error) {
        // Error already logged in updateRepo, continue with next repo
      }
    }
  }

  private printSummary(): void {
    console.log(`\n${BOLD}SUMMARY${RESET}`);
    console.log('='.repeat(50));

    const successful = this.repos.filter(r => r.status === 'success');
    const failed = this.repos.filter(r => r.status === 'error');
    const skipped = this.repos.filter(r => r.hasUncommittedChanges && this.mode === 'refresh');

    if (successful.length > 0) {
      console.log(`${GREEN}Successful (${successful.length}):${RESET}`);
      successful.forEach(repo => console.log(`${GREEN}   ${repo.name.padEnd(25)}   Completed${RESET}`));
    }

    if (failed.length > 0) {
      console.log(`${RED}Failed (${failed.length}):${RESET}`);
      failed.forEach(repo => console.log(`${RED}   ${repo.name.padEnd(25)}   ${repo.error?.split('\n')[0] || 'Unknown error'}${RESET}`));
    }

    if (skipped.length > 0) {
      console.log(`${YELLOW}Skipped (${skipped.length}):${RESET}`);
      skipped.forEach(repo => console.log(`${YELLOW}   ${repo.name.padEnd(25)}   Uncommitted changes${RESET}`));
    }
  }

  public async run(): Promise<void> {
    try {
      console.log(`${BOLD}Repository ${this.mode.toUpperCase()} Script${RESET}`);
      console.log('='.repeat(50));

      if (this.mode === 'refresh') {
        console.log(`Branch: ${this.branch}`);
      }

      // Show which repositories will be processed
      if (this.targetRepos !== REPOSITORIES) {
        console.log('Target repositories specified:');
        this.targetRepos.forEach(repo => console.log(`   ${repo}`));
        console.log('');
      }

      await this.initializeRepos();

      if (this.repos.length === 0) {
        console.log(`${RED}No valid repositories found. Exiting.${RESET}`);
        return;
      }

      const proceed = await this.confirmPreconditions();
      if (!proceed) {
        return;
      }

      await this.updateReposInParallel();
      this.printSummary();

    } catch (error) {
      console.error(`${RED}Unexpected error:${RESET}`, error);
    } finally {
      this.rl.close();
    }
  }
}

// Run the script
if (require.main === module) {
  // Parse command line arguments
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error(`${RED}Error: Command mode required. Use "refresh" or "terminate"${RESET}`);
    console.error('\nUsage:');
    console.error('  npx tsx scripts/repo-manager.ts refresh [--branch <name>] [repo1] [repo2]');
    console.error('  npx tsx scripts/repo-manager.ts terminate [repo1] [repo2]');
    process.exit(1);
  }

  const mode = args[0] as CommandMode;
  if (mode !== 'refresh' && mode !== 'terminate') {
    console.error(`${RED}Error: Invalid command "${mode}". Use "refresh" or "terminate"${RESET}`);
    process.exit(1);
  }

  // Parse --branch flag and remaining repo names
  const remaining = args.slice(1);
  let branch: string | undefined;
  const targetRepos: string[] = [];

  for (let i = 0; i < remaining.length; i++) {
    if (remaining[i] === '--branch') {
      branch = remaining[i + 1];
      if (!branch) {
        console.error(`${RED}Error: --branch requires a branch name${RESET}`);
        process.exit(1);
      }
      i++; // skip the branch name
    } else {
      targetRepos.push(remaining[i]);
    }
  }

  const updater = new RepoUpdater(mode, targetRepos, branch);
  updater.run().catch(console.error);
}

export default RepoUpdater;

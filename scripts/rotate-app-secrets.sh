#!/bin/bash
set -eo pipefail

# ============================================
# rotate-app-secrets.sh
#
# Purpose:
#   Rotates application secrets in a cloud.gov space.
#   Reads secrets from a file, applies them to all apps
#   via cf set-env, and optionally updates GitHub secrets.
#
# How it works:
#   1. Sources the provided secrets file to load all variables.
#   2. For each app, sources its repo's scripts/environment-variables-secrets.sh
#      which runs cf set-env to apply the secrets.
#   3. For non-prod spaces, also updates GitHub Actions secrets
#      (per-environment) so CI/CD deployments stay in sync.
#   4. Restages all modified apps one at a time.
#
# Prerequisites:
#   - cf CLI installed and logged in (cf login)
#   - gh CLI installed and authenticated (non-prod only, unless --skip-gh-secrets)
#   - Login to gh with: gh auth login
#   - All easey-* repos checked out locally under EASEY_APPS_LOCAL_REPO_ROOT
#   - A populated secrets file (see devops/scripts/secrets-prod.txt for format)
#
# Arguments:
#   <secrets-file>  Path to secrets file (e.g., devops/scripts/secrets-dev.txt)
#   <cf-space>      Cloud Foundry space (dev, test, perf, beta, staging, prod)
#
# Options:
#   --test <vars>        Only rotate the specified comma-separated secrets.txt
#                        variables. Spaces around commas are allowed.
#   --skip-gh-secrets    Skip updating GitHub secrets (non-prod only).
#
# Environment variables:
#   EASEY_APPS_LOCAL_REPO_ROOT  Override the root directory where all easey-*
#                               repos are checked out. Defaults to ../../ relative
#                               to this script (i.e., the parent of the devops repo).
#
# Examples:
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev
#   ./scripts/rotate-app-secrets.sh scripts/secrets-prod.txt prod
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev --test "ACCOUNT_API_KEY, CAMD_SERVICES_SECRET_TOKEN"
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev --skip-gh-secrets --test "ACCOUNT_API_SECRET_TOKEN, CAMD_SERVICES_SECRET_TOKEN"
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev --skip-gh-secrets
#
# ============================================

# --- ANSI color codes ---
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Logging helpers ---
log()  { echo ""; echo -e "${BOLD}>>> [rotate] $1${RESET}"; }
info() { echo -e ">>> [rotate]   $1"; }
warn() { echo -e "${YELLOW}>>> [rotate]   WARNING: $1${RESET}"; }
err()  { echo -e "${RED}>>> [rotate]   ERROR: $1${RESET}" >&2; }

# --- Usage ---
usage() {
  echo "Usage: $0 <secrets-file> <cf-space> [options]"
  echo ""
  echo "Arguments:"
  echo "  <secrets-file>  Path to secrets file (e.g., devops/scripts/secrets-dev.txt)"
  echo "  <cf-space>      Cloud Foundry space (dev, test, perf, beta, staging, prod)"
  echo ""
  echo "Options:"
  echo "  --test <vars>   Only rotate the specified comma-separated secrets.txt variables."
  echo "                  Spaces around commas are allowed."
  echo "                  Example: --test \"ACCOUNT_API_KEY, AUTH_API_SECRET_TOKEN\""
  echo "  --skip-gh-secrets  Skip updating GitHub secrets (non-prod environments only)."
  echo ""
  echo "Examples:"
  echo "  $0 devops/scripts/secrets-dev.txt dev"
  echo "  $0 devops/scripts/secrets-prod.txt prod"
  echo "  $0 devops/scripts/secrets-dev.txt dev --test ACCOUNT_API_KEY,AUTH_API_SECRET_TOKEN"
  echo "  $0 devops/scripts/secrets-dev.txt dev --skip-gh-secrets"
  exit 1
}

# ============================================
# Parse arguments
# ============================================

SECRETS_FILE=""
CF_SPACE=""
TEST_MODE=false
TEST_VARS=""
SKIP_GH_SECRETS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --test)
      TEST_MODE=true
      if [ -z "$2" ] || [[ "$2" == --* ]]; then
        err "--test requires a comma-separated list of variable names."
        exit 1
      fi
      TEST_VARS="$2"
      shift 2
      ;;
    --skip-gh-secrets)
      SKIP_GH_SECRETS=true
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      if [ -z "$SECRETS_FILE" ]; then
        SECRETS_FILE="$1"
      elif [ -z "$CF_SPACE" ]; then
        CF_SPACE="$1"
      else
        err "Unexpected argument: $1"
        usage
      fi
      shift
      ;;
  esac
done

if [ -z "$SECRETS_FILE" ] || [ -z "$CF_SPACE" ]; then
  usage
fi

# ============================================
# Configuration
# ============================================

# Root directory where all easey-* repos are checked out locally.
# Override by exporting EASEY_APPS_LOCAL_REPO_ROOT before running.
EASEY_APPS_LOCAL_REPO_ROOT="${EASEY_APPS_LOCAL_REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

GH_ORG="US-EPA-CAMD"
CF_ORG_NAME="epa-easey"

# ============================================
# App-to-repo mapping
# Format: "cf-app-name:github-repo-name"
# ============================================

APP_REPO_MAP=(
  "auth-api:easey-auth-api"
  "account-api:easey-account-api"
  "camd-services:easey-camd-services"
  "emissions-api:easey-emissions-api"
  "facilities-api:easey-facilities-api"
  "mdm-api:easey-mdm-api"
  "monitor-plan-api:easey-monitor-plan-api"
  "qa-certification-api:easey-qa-certification-api"
  "streaming-services:easey-streaming-services"
  "quartz-scheduler:easey-quartz-scheduler"
  "campd-ui:easey-campd-ui"
  "ecmps-ui:easey-ecmps-ui"
)

# ============================================
# CF space to GitHub environment mapping
# ============================================

get_gh_env() {
  case "$1" in
    dev)     echo "Dev" ;;
    test)    echo "Test" ;;
    perf)    echo "Performance" ;;
    beta)    echo "Beta" ;;
    staging) echo "Staging" ;;
    prod)    echo "Production" ;;
    *)       err "Unknown CF space: $1"; exit 1 ;;
  esac
}

# ============================================
# GitHub secret mapping
#
# Dynamically resolved at runtime by matching
# secrets.txt variable names against workflow
# files in each repo. The workflow pattern is:
#   <SECRETS_TXT_VAR>: ${{ secrets.<GH_SECRET_NAME> }}
# ============================================

# Resolves the GitHub secret name for a given secrets.txt variable
# by searching the repo's workflow files.
# Usage: resolve_gh_secret_name <repo_name> <secrets_txt_var>
# Prints the GitHub secret name or returns 1 if not found.
resolve_gh_secret_name() {
  local repo_name="$1"
  local secrets_txt_var="$2"
  local workflows_dir="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/.github/workflows"

  if [ ! -d "$workflows_dir" ]; then
    return 1
  fi

  # Match pattern: <SECRETS_TXT_VAR>: ${{ secrets.<GH_SECRET_NAME> }}
  # Anchored with leading whitespace to prevent partial variable name matches
  local match
  match=$(grep -rhE "^[[:space:]]+${secrets_txt_var}:.*secrets\." "$workflows_dir"/*.yml 2>/dev/null | head -1)

  if [ -z "$match" ]; then
    return 1
  fi

  # Extract the GitHub secret name from: ${{ secrets.NAME }}
  local gh_name
  gh_name=$(echo "$match" | sed -n 's/.*secrets\.\([A-Za-z_][A-Za-z0-9_]*\).*/\1/p')

  if [ -z "$gh_name" ]; then
    return 1
  fi

  echo "$gh_name"
  return 0
}

# Builds the GH_SECRET_MAP dynamically from workflow files.
# Format: "repo-name:gh-secret-name:secrets-txt-variable"
build_gh_secret_map() {
  GH_SECRET_MAP=()

  for entry in "${APP_REPO_MAP[@]}"; do
    local app_name="${entry%%:*}"
    local repo_name="${entry#*:}"
    local script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

    [ ! -f "$script_path" ] && continue

    # Extract all secrets.txt variable names from the environment-variables-secrets.sh
    while IFS= read -r line || [ -n "$line" ]; do
      [[ -z "$line" ]] && continue
      [[ "$line" =~ ^[[:space:]]*# ]] && continue

      local secrets_txt_var
      if ! secrets_txt_var="$(extract_source_secret_var "$line")"; then
        continue
      fi

      local gh_secret
      if gh_secret="$(resolve_gh_secret_name "$repo_name" "$secrets_txt_var")"; then
        GH_SECRET_MAP+=("$repo_name:$gh_secret:$secrets_txt_var")
      else
        warn "No GitHub secret mapping found for '$secrets_txt_var' in $repo_name workflows. Skipping GH update for this variable."
      fi
    done < "$script_path"
  done
}

# ============================================
# Helper functions
# ============================================

should_process_secret_var() {
  local candidate="$1"

  if [ "$TEST_MODE" != "true" ]; then
    return 0
  fi

  local var
  for var in "${TEST_VAR_ARRAY[@]}"; do
    if [ "$candidate" = "$var" ]; then
      return 0
    fi
  done

  return 1
}

get_app_name_for_repo() {
  local repo="$1"
  local entry

  for entry in "${APP_REPO_MAP[@]}"; do
    local app_name="${entry%%:*}"
    local repo_name="${entry#*:}"
    if [ "$repo_name" = "$repo" ]; then
      echo "$app_name"
      return 0
    fi
  done

  return 1
}

join_by_comma() {
  local IFS=", "
  echo "$*"
}

normalize_source_var_token() {
  local token="$1"

  token="${token%\"}"
  token="${token#\"}"
  token="${token%\'}"
  token="${token#\'}"

  if [[ "$token" =~ ^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ "$token" =~ ^\$([A-Za-z_][A-Za-z0-9_]*)$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi

  return 1
}

extract_source_secret_var() {
  local line="$1"
  local value_token=""

  # Supported/standardized command shapes:
  #   cf set-env $APP_NAME SOME_ENV_VAR $SECRET_VAR
  #   cf set-env "$APP_NAME" SOME_ENV_VAR "$SECRET_VAR"
  #   cf set-env $APP_NAME SOME_ENV_VAR ${SECRET_VAR}
  #   command cf set-env $APP_NAME SOME_ENV_VAR $SECRET_VAR
  #   ... with optional trailing inline comment
  if [[ "$line" =~ ^[[:space:]]*(command[[:space:]]+)?cf[[:space:]]+set-env[[:space:]]+(\$APP_NAME|\"\$APP_NAME\"|\'\$APP_NAME\')[[:space:]]+([A-Za-z0-9_]+|\"[^\"]+\"|\'[^\']+\')[[:space:]]+(\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\"\$\{[A-Za-z_][A-Za-z0-9_]*\}\"|\"\$[A-Za-z_][A-Za-z0-9_]*\"|\'\$\{[A-Za-z_][A-Za-z0-9_]*\}\'|\'\$[A-Za-z_][A-Za-z0-9_]*\')[[:space:]]*([#].*)?$ ]]; then
    value_token="${BASH_REMATCH[4]}"
    normalize_source_var_token "$value_token"
    return $?
  fi

  return 1
}

run_test_mode_setenv_for_app() {
  local app_name="$1"
  local script_path="$2"
  local matched_count=0
  local applied_count=0
  local failed_count=0
  local line=""
  local source_var=""
  local masked=""

  TEST_LAST_MATCHED_VARS=()
  TEST_LAST_APPLIED_VARS=()
  TEST_LAST_FAILED_VARS=()

  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    source_var=""
    if ! source_var="$(extract_source_secret_var "$line")"; then
      continue
    fi

    if ! should_process_secret_var "$source_var"; then
      continue
    fi

    if [ -z "${!source_var+x}" ] || [ -z "${!source_var}" ]; then
      err "Required secret '$source_var' for app '$app_name' is missing or empty."
      exit 1
    fi

    matched_count=$((matched_count + 1))
    TEST_LAST_MATCHED_VARS+=("$source_var")

    masked=$(echo "$line" | sed 's/\$[A-Za-z_][A-Za-z_0-9]*/****/g; s/\${[A-Za-z_][A-Za-z_0-9]*}/****/g')
    info "[$app_name] $masked"

    if (
      export APP_NAME="$app_name"
      eval "$line"
    ); then
      applied_count=$((applied_count + 1))
      TEST_LAST_APPLIED_VARS+=("$source_var")
    else
      failed_count=$((failed_count + 1))
      TEST_LAST_FAILED_VARS+=("$source_var")
      break
    fi
  done < "$script_path"

  if [ "$matched_count" -eq 0 ]; then
    return 2
  fi

  if [ "$applied_count" -gt 0 ] && [ "$failed_count" -gt 0 ]; then
    return 3
  fi

  if [ "$failed_count" -gt 0 ]; then
    return 1
  fi

  return 0
}

print_grouped_github_secret_summary() {
  local logger="$1"
  shift
  local details=("$@")

  if [ ${#details[@]} -eq 0 ]; then
    $logger "0"
    return
  fi

  $logger "${#details[@]}"

  local entry
  for entry in "${VALID_APPS[@]}"; do
    local app_name="${entry%%:*}"
    local secrets=()
    local detail
    for detail in "${details[@]}"; do
      local detail_app="${detail%%:*}"
      local detail_secret="${detail#*:}"
      if [ "$detail_app" = "$app_name" ]; then
        secrets+=("$detail_secret")
      fi
    done

    if [ ${#secrets[@]} -gt 0 ]; then
      $logger "  - $app_name: $(join_by_comma "${secrets[@]}")"
    fi
  done
}

# ============================================
# Validate prerequisites
# ============================================

log "Validating prerequisites..."

if ! command -v cf &> /dev/null; then
  err "Cloud Foundry CLI (cf) not found."
  exit 1
fi
info "cf CLI found."

if [ "$CF_SPACE" != "prod" ] && [ "$SKIP_GH_SECRETS" = false ]; then
  if ! command -v gh &> /dev/null; then
    err "GitHub CLI (gh) not found. Install it or use --skip-gh-secrets to skip."
    exit 1
  fi
  info "gh CLI found."
fi

# ============================================
# Validate inputs
# ============================================

log "Validating inputs..."

if [ ! -f "$SECRETS_FILE" ]; then
  err "Secrets file not found: $SECRETS_FILE"
  exit 1
fi

VALID_SPACES="dev test perf beta staging prod"
if [[ ! " $VALID_SPACES " =~ " $CF_SPACE " ]]; then
  err "Invalid CF space: $CF_SPACE. Must be one of: $VALID_SPACES"
  exit 1
fi

GH_ENV=$(get_gh_env "$CF_SPACE")

info "Secrets file:       $SECRETS_FILE"
info "CF space:           $CF_SPACE"
info "GitHub environment: $GH_ENV"
info "Skip GitHub:        $SKIP_GH_SECRETS"
info "Repo root:          $EASEY_APPS_LOCAL_REPO_ROOT"
if [ "$TEST_MODE" = true ]; then
  info "Mode:               Test with Selected Secrets (only the following will be updated in '$CF_SPACE'):"
  IFS=',' read -ra PREVIEW_VARS <<< "$TEST_VARS"
  for v in "${PREVIEW_VARS[@]}"; do
    info "                      $(echo "$v" | xargs)"
  done
else
  info "Mode:               FULL (all secrets will be updated in '$CF_SPACE')"
fi

# ============================================
# Load secrets
# ============================================

log "Loading secrets..."
source "$SECRETS_FILE"
info "Secrets loaded."

# ============================================
# Validate test variables (if --test)
# ============================================

TEST_VAR_ARRAY=()

if [ "$TEST_MODE" = true ]; then
  log "Validating test variables..."

  IFS=',' read -ra RAW_VARS <<< "$TEST_VARS"
  for raw in "${RAW_VARS[@]}"; do
    trimmed=$(echo "$raw" | xargs)
    [ -z "$trimmed" ] && continue
    TEST_VAR_ARRAY+=("$trimmed")
  done

  if [ ${#TEST_VAR_ARRAY[@]} -eq 0 ]; then
    err "No valid variable names provided to --test."
    exit 1
  fi

  for var in "${TEST_VAR_ARRAY[@]}"; do
    if [ -z "${!var+x}" ]; then
      err "Variable '$var' not found in secrets file: $SECRETS_FILE"
      exit 1
    fi
    if [ -z "${!var}" ]; then
      err "Variable '$var' is empty in secrets file: $SECRETS_FILE"
      exit 1
    fi
    info "$var [OK]"
  done
fi

# ============================================
# Validate local repos and scripts
# ============================================

log "Validating local repos and scripts..."

if [ ! -d "$EASEY_APPS_LOCAL_REPO_ROOT" ]; then
  err "Repo root directory not found: $EASEY_APPS_LOCAL_REPO_ROOT"
  exit 1
fi

info "Repo root: $EASEY_APPS_LOCAL_REPO_ROOT"
info ""
info "The following repos will be used to source environment-variables-secrets.sh."
info "Make sure each repo is checked out to the latest branch before proceeding."
info "You can use this script/command: npx tsx scripts/repo-manager.ts refresh --branch develop"
info ""

for entry in "${APP_REPO_MAP[@]}"; do
  app_name="${entry%%:*}"
  repo_name="${entry#*:}"
  script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

  if [ ! -f "$script_path" ]; then
    err "Script not found: $script_path"
    exit 1
  fi

  if [ ! -r "$script_path" ]; then
    err "Script is not readable: $script_path"
    exit 1
  fi

  info "  $repo_name/scripts/environment-variables-secrets.sh [OK]"
done

echo ""
read -p ">>> [rotate] Have you verified all repos are up to date? (y/n): " repo_confirm
if [ "$repo_confirm" != "y" ]; then
  err "Aborted. Please update your local repos and re-run."
  exit 1
fi

# ============================================
# Production confirmation guard
# ============================================

if [ "$CF_SPACE" = "prod" ]; then
  echo ""
  echo ">>> ============================================"
  echo ">>>   WARNING: PRODUCTION ENVIRONMENT"
  echo ">>>   You are about to rotate secrets in prod."
  echo ">>> ============================================"
  echo ""
  read -p ">>> Type 'prod' to confirm: " confirm
  echo ""
  if [ "$confirm" != "prod" ]; then
    err "Aborted by user."
    exit 1
  fi
fi

# ============================================
# Target Cloud Foundry
# ============================================

log "Targeting Cloud Foundry (assumes you are already logged in)..."
if ! cf target -o "$CF_ORG_NAME" -s "$CF_SPACE"; then
  err "Failed to target org='$CF_ORG_NAME' space='$CF_SPACE'. Are you logged in?"
  exit 1
fi
info "Targeted org=$CF_ORG_NAME space=$CF_SPACE"

# ============================================
# Validate apps exist in CF space
# ============================================

log "Validating apps exist in space '$CF_SPACE'..."

VALID_APPS=()
for entry in "${APP_REPO_MAP[@]}"; do
  app_name="${entry%%:*}"
  if cf app "$app_name" --guid > /dev/null 2>&1; then
    info "$app_name [OK]"
    VALID_APPS+=("$entry")
  else
    warn "$app_name not found in space '$CF_SPACE'. Skipping."
  fi
done

if [ ${#VALID_APPS[@]} -eq 0 ]; then
  err "No valid apps found in space '$CF_SPACE'."
  exit 1
fi

info "${#VALID_APPS[@]} app(s) found."

# ============================================
# Build GitHub secret mapping (non-prod only)
# ============================================

GH_SECRET_MAP=()

if [ "$CF_SPACE" != "prod" ] && [ "$SKIP_GH_SECRETS" = false ]; then
  log "Building GitHub secret mapping from workflow files..."
  build_gh_secret_map

  if [ ${#GH_SECRET_MAP[@]} -eq 0 ]; then
    err "No GitHub secret mappings could be resolved from workflow files."
    exit 1
  fi
  info "${#GH_SECRET_MAP[@]} mapping(s) resolved."
fi

# ============================================
# Update GitHub secrets (non-prod only)
# ============================================

GH_UPDATED=0
GH_FAILED=0
GH_UPDATED_DETAILS=()
GH_FAILED_DETAILS=()

if [ "$CF_SPACE" != "prod" ] && [ "$SKIP_GH_SECRETS" = false ]; then
  log "Updating GitHub secrets for environment '$GH_ENV'..."

  for mapping in "${GH_SECRET_MAP[@]}"; do
    repo="${mapping%%:*}"
    rest="${mapping#*:}"
    gh_secret="${rest%%:*}"
    secrets_var="${rest#*:}"
    app_name="$(get_app_name_for_repo "$repo")"

    if ! should_process_secret_var "$secrets_var"; then
      continue
    fi

    if [ -z "${!secrets_var+x}" ] || [ -z "${!secrets_var}" ]; then
      err "Required secret '$secrets_var' for repo '$repo' GitHub secret '$gh_secret' is missing or empty."
      exit 1
    fi

    value="${!secrets_var}"
    info "$app_name -> $gh_secret (from $secrets_var)"

    if printf '%s' "$value" | gh secret set "$gh_secret" --repo "$GH_ORG/$repo" --env "$GH_ENV"; then
      GH_UPDATED=$((GH_UPDATED + 1))
      GH_UPDATED_DETAILS+=("$app_name:$gh_secret")
    else
      GH_FAILED=$((GH_FAILED + 1))
      GH_FAILED_DETAILS+=("$app_name:$gh_secret")
      err "Failed to update GitHub secret '$gh_secret' for app '$app_name' (repo '$repo')."
    fi
    unset value
  done

  info "$GH_UPDATED GitHub secret(s) updated."

elif [ "$CF_SPACE" = "prod" ]; then
  log "Production environment. Skipping GitHub secrets."
else
  log "Skipping GitHub secrets (--skip-gh-secrets)."
fi

# ============================================
# Apply secrets via cf set-env
# ============================================

MODIFIED_APPS=()
SETENV_SUCCEEDED=()
SETENV_FAILED=()
SETENV_SKIPPED=()
SETENV_PARTIAL=()
SETENV_PARTIAL_DETAILS=()
SETENV_FAILED_DETAILS=()

if [ "$TEST_MODE" = true ]; then
  log "Test mode: applying only specified variables via cf set-env..."

  for entry in "${VALID_APPS[@]}"; do
    app_name="${entry%%:*}"
    repo_name="${entry#*:}"
    script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

    if run_test_mode_setenv_for_app "$app_name" "$script_path"; then
      MODIFIED_APPS+=("$app_name")
      SETENV_SUCCEEDED+=("$app_name")
      info "$app_name set-env completed."
    else
      status=$?
      if [ "$status" -eq 2 ]; then
        SETENV_SKIPPED+=("$app_name")
        info "$app_name had no matching --test variables. Skipping."
      elif [ "$status" -eq 3 ]; then
        MODIFIED_APPS+=("$app_name")
        SETENV_PARTIAL+=("$app_name")
        SETENV_PARTIAL_DETAILS+=("$app_name:applied($(join_by_comma "${TEST_LAST_APPLIED_VARS[@]}")) failed($(join_by_comma "${TEST_LAST_FAILED_VARS[@]}"))")
        err "$app_name partially completed during set-env. Applied: $(join_by_comma "${TEST_LAST_APPLIED_VARS[@]}"). Failed: $(join_by_comma "${TEST_LAST_FAILED_VARS[@]}")."
      else
        SETENV_FAILED+=("$app_name")
        if [ ${#TEST_LAST_FAILED_VARS[@]} -gt 0 ]; then
          SETENV_FAILED_DETAILS+=("$app_name:$(join_by_comma "${TEST_LAST_FAILED_VARS[@]}")")
          err "$app_name failed during set-env. Failed variables: $(join_by_comma "${TEST_LAST_FAILED_VARS[@]}")."
        else
          err "$app_name failed during set-env."
        fi
      fi
    fi
  done

else
  log "Applying all secrets via cf set-env..."

  for entry in "${VALID_APPS[@]}"; do
    app_name="${entry%%:*}"
    repo_name="${entry#*:}"
    script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

    log "Setting secrets: $app_name"
    if (
      export APP_NAME="$app_name"
      source "$script_path"
    ); then
      MODIFIED_APPS+=("$app_name")
      SETENV_SUCCEEDED+=("$app_name")
      info "$app_name set-env completed."
    else
      SETENV_FAILED+=("$app_name")
      err "$app_name failed during set-env."
    fi
  done
fi

# ============================================
# Restage apps (one at a time)
# ============================================

RESTAGE_SUCCEEDED=()
RESTAGE_FAILED=()

if [ ${#MODIFIED_APPS[@]} -eq 0 ]; then
  log "No apps were modified. Skipping restage."
else
  log "Restaging ${#MODIFIED_APPS[@]} app(s) one at a time..."
  for app in "${MODIFIED_APPS[@]}"; do
    log "Restaging $app..."
    if cf restage "$app"; then
      RESTAGE_SUCCEEDED+=("$app")
      info "$app restaged successfully."
    else
      RESTAGE_FAILED+=("$app")
      err "$app failed to restage."
    fi
  done
fi

# ============================================
# Summary
# ============================================

log "=== Rotation Summary ==="
info "Space: $CF_SPACE"

info "Set-env succeeded: ${#SETENV_SUCCEEDED[@]}"
for app in "${SETENV_SUCCEEDED[@]}"; do
  info "  - $app"
done

info "Set-env partial:   ${#SETENV_PARTIAL[@]}"
for detail in "${SETENV_PARTIAL_DETAILS[@]}"; do
  err "  - $detail"
done

info "Set-env skipped:   ${#SETENV_SKIPPED[@]}"
for app in "${SETENV_SKIPPED[@]}"; do
  info "  - $app"
done

info "Set-env failed:    ${#SETENV_FAILED[@]}"
for app in "${SETENV_FAILED[@]}"; do
  err "  - $app"
done
for detail in "${SETENV_FAILED_DETAILS[@]}"; do
  err "    details: $detail"
done

info "Restage succeeded: ${#RESTAGE_SUCCEEDED[@]}"
for app in "${RESTAGE_SUCCEEDED[@]}"; do
  info "  - $app"
done

info "Restage failed:    ${#RESTAGE_FAILED[@]}"
for app in "${RESTAGE_FAILED[@]}"; do
  err "  - $app"
done

if [ "$CF_SPACE" != "prod" ] && [ "$SKIP_GH_SECRETS" = false ]; then
  info "GitHub secrets updated by app:"
  print_grouped_github_secret_summary info "${GH_UPDATED_DETAILS[@]}"

  info "GitHub secrets failed by app:"
  print_grouped_github_secret_summary err "${GH_FAILED_DETAILS[@]}"
elif [ "$SKIP_GH_SECRETS" = true ]; then
  info "GitHub secrets: skipped (--skip-gh-secrets)"
else
  info "GitHub secrets: N/A (prod)"
fi

if [ "$TEST_MODE" = true ]; then
  info "Test variables: ${TEST_VAR_ARRAY[*]}"
fi

if [ ${#SETENV_FAILED[@]} -gt 0 ] || [ ${#SETENV_PARTIAL[@]} -gt 0 ] || [ ${#RESTAGE_FAILED[@]} -gt 0 ] || [ "$GH_FAILED" -gt 0 ]; then
  err "Completed with failures."
  exit 1
fi

info "Done."

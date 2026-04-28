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
#   2. For each app, parses its repo's scripts/environment-variables-secrets.sh
#      and runs cf set-env for each variable found.
#   3. For non-prod spaces, also updates GitHub Actions secrets
#      (per-environment) so CI/CD deployments stay in sync.
#   4. Restages all modified apps one at a time.
#
# Repository-level vs Environment-level GitHub secrets:
#   Some secrets (API_KEY, CLIENT_ID, CLIENT_SECRET) are set at the
#   GitHub repository level, not per-environment. These use the same
#   value across all non-prod environments and a separate value for prod.
#   The script detects these automatically and sets them without --env.
#
#   Because repo-level secrets are shared across environments, they only
#   need to be rotated twice:
#     1. Once for non-prod (any single run against dev, test, etc. updates
#        the repo-level secret for all non-prod environments).
#     2. Once for prod (via deploy-all.sh or manual update).
#
#   Use the same value for these secrets across all non-prod environments.
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
#   --skip-gh-secrets    Skip updating GitHub secrets (non-prod only).
#   --skip-missing       Skip variables not found in the secrets file instead of failing.
#
# Environment variables:
#   EASEY_APPS_LOCAL_REPO_ROOT  Override the root directory where all easey-*
#                               repos are checked out. Defaults to ../../ relative
#                               to this script (i.e., the parent of the devops repo).
#
# Examples:
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev
#   ./scripts/rotate-app-secrets.sh scripts/secrets-dev.txt dev --skip-missing
#   ./scripts/rotate-app-secrets.sh scripts/secrets-prod.txt prod
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
  echo "  --skip-gh-secrets  Skip updating GitHub secrets (non-prod environments only)."
  echo "  --skip-missing     Skip variables not found in the secrets file instead of failing."
  echo ""
  echo "Examples:"
  echo "  $0 devops/scripts/secrets-dev.txt dev"
  echo "  $0 devops/scripts/secrets-prod.txt prod"
  echo "  $0 devops/scripts/secrets-dev.txt dev --skip-gh-secrets"
  echo "  $0 devops/scripts/secrets-dev.txt dev --skip-missing"
  exit 1
}

# ============================================
# Parse arguments
# ============================================

SECRETS_FILE=""
CF_SPACE=""
SKIP_GH_SECRETS=false
SKIP_MISSING=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-gh-secrets)
      SKIP_GH_SECRETS=true
      shift
      ;;
    --skip-missing)
      SKIP_MISSING=true
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
  match=$(grep -rhE --include='*.yml' --include='*.yaml' "^[[:space:]]+${secrets_txt_var}:.*secrets\." "$workflows_dir" 2>/dev/null | head -1)

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
    local repo_name="${entry#*:}"
    local script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

    [ ! -f "$script_path" ] && continue

    local line=""
    local mapping=""
    local source_var=""
    local gh_secret=""

    while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
      [[ -z "$line" ]] && continue
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" =~ ^[[:space:]]*#!/bin/bash[[:space:]]*$ ]] && continue

      if ! mapping="$(parse_setenv_mapping_line "$line")"; then
        err "Unsupported line found while building GitHub secret map in $repo_name: $line"
        exit 1
      fi

      source_var="${mapping#*|}"

      if gh_secret="$(resolve_gh_secret_name "$repo_name" "$source_var")"; then
        GH_SECRET_MAP+=("$repo_name:$gh_secret:$source_var")
      else
        warn "No GitHub secret mapping found for '$source_var' in $repo_name workflows. Skipping GH update for this variable."
      fi
    done < "$script_path"
  done
}

# ============================================
# Helper functions
# ============================================

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

# Parses a single allowed line shape from environment-variables-secrets.sh
# Allowed shapes:
#   cf set-env $APP_NAME TARGET_ENV_VAR $SOURCE_SECRET_VAR
#   cf set-env "$APP_NAME" TARGET_ENV_VAR "$SOURCE_SECRET_VAR"
#   command cf set-env $APP_NAME TARGET_ENV_VAR $SOURCE_SECRET_VAR
#
# Output format:
#   TARGET_ENV_VAR|SOURCE_SECRET_VAR
parse_setenv_mapping_line() {
  local line="$1"

  if [[ "$line" =~ ^[[:space:]]*(command[[:space:]]+)?cf[[:space:]]+set-env[[:space:]]+(\$APP_NAME|\"\$APP_NAME\"|\'\$APP_NAME\')[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)[[:space:]]+(\$[A-Za-z_][A-Za-z0-9_]*|\"\$[A-Za-z_][A-Za-z0-9_]*\"|\'\$[A-Za-z_][A-Za-z0-9_]*\')[[:space:]]*$ ]]; then
    local target_env_var="${BASH_REMATCH[3]}"
    local source_token="${BASH_REMATCH[4]}"

    source_token="${source_token%\"}"
    source_token="${source_token#\"}"
    source_token="${source_token%\'}"
    source_token="${source_token#\'}"
    source_token="${source_token#\$}"

    echo "${target_env_var}|${source_token}"
    return 0
  fi

  return 1
}

# Validates that a repo's environment-variables-secrets.sh only contains:
#   - blank lines
#   - comments
#   - shebang
#   - supported cf set-env lines
validate_env_script_format() {
  local repo_name="$1"
  local script_path="$2"
  local line=""
  local line_no=0
  local mapping=""
  local target_env_var=""
  local source_var=""
  local seen_targets=()

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    line_no=$((line_no + 1))

    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*#!/bin/bash[[:space:]]*$ ]] && continue

    if ! mapping="$(parse_setenv_mapping_line "$line")"; then
      err "Invalid line format in $repo_name ($script_path:$line_no): $line"
      err "Expected: cf set-env \$APP_NAME TARGET_ENV_VAR \$SOURCE_SECRET_VAR"
      return 1
    fi

    target_env_var="${mapping%%|*}"
    source_var="${mapping#*|}"

    if [[ " ${seen_targets[*]} " == *" ${target_env_var} "* ]]; then
      err "Duplicate target env var '$target_env_var' in $repo_name ($script_path:$line_no)."
      return 1
    fi
    seen_targets+=("$target_env_var")

    if [[ -z "$source_var" ]]; then
      err "Missing source variable in $repo_name ($script_path:$line_no)."
      return 1
    fi
  done < "$script_path"

  return 0
}

print_grouped_github_secret_summary() {
  local logger="$1"
  shift
  local details=("$@")

  if [ ${#details[@]} -eq 0 ]; then
    info "0"
    return
  fi

  info "${#details[@]}"

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
info "Skip missing:       $SKIP_MISSING"
info "Repo root:          $EASEY_APPS_LOCAL_REPO_ROOT"
info "Mode:               All secrets in the secrets file will be updated in '$CF_SPACE'"

# ============================================
# Load secrets
# ============================================

log "Loading secrets..."
source "$SECRETS_FILE"
info "Secrets loaded."

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

  if ! validate_env_script_format "$repo_name" "$script_path"; then
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

# GitHub secrets that are set at the repository level (same value across
# all non-prod environments) rather than per-environment.
GH_REPO_LEVEL_SECRETS=("API_KEY")

GH_SECRET_MAP=()

if [ "$CF_SPACE" != "prod" ] && [ "$SKIP_GH_SECRETS" = false ]; then
  log "Building GitHub secret mapping from workflow files..."
  build_gh_secret_map

  if [ ${#GH_SECRET_MAP[@]} -eq 0 ]; then
    err "No GitHub secret mappings could be resolved from workflow files."
    exit 1
  fi
  info "${#GH_SECRET_MAP[@]} per-app mapping(s) resolved."
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

    if [ -z "${!secrets_var+x}" ] || [ -z "${!secrets_var}" ]; then
      if [ "$SKIP_MISSING" = true ]; then
        warn "Skipping GitHub secret '$gh_secret' for $repo ($secrets_var missing or empty)."
        continue
      fi
      err "Required secret '$secrets_var' for repo '$repo' GitHub secret '$gh_secret' is missing or empty. Use --skip-missing to skip."
      exit 1
    fi

    value="${!secrets_var}"

    if [[ " ${GH_REPO_LEVEL_SECRETS[*]} " == *" $gh_secret "* ]]; then
      info "$app_name -> $gh_secret (from $secrets_var) [repo-level]"
      gh_set_cmd=(gh secret set "$gh_secret" --repo "$GH_ORG/$repo")
    else
      info "$app_name -> $gh_secret (from $secrets_var) [env: $GH_ENV]"
      gh_set_cmd=(gh secret set "$gh_secret" --repo "$GH_ORG/$repo" --env "$GH_ENV")
    fi

    if printf '%s' "$value" | "${gh_set_cmd[@]}"; then
      GH_UPDATED=$((GH_UPDATED + 1))
      GH_UPDATED_DETAILS+=("$app_name:$gh_secret")
    else
      GH_FAILED=$((GH_FAILED + 1))
      GH_FAILED_DETAILS+=("$app_name:$gh_secret")
      err "Failed to update GitHub secret '$gh_secret' for app '$app_name' (repo '$repo')."
    fi
    unset value
  done

  info "$GH_UPDATED GitHub secret(s) updated total."

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

log "Applying secrets via cf set-env..."

for entry in "${VALID_APPS[@]}"; do
  app_name="${entry%%:*}"
  repo_name="${entry#*:}"
  script_path="$EASEY_APPS_LOCAL_REPO_ROOT/$repo_name/scripts/environment-variables-secrets.sh"

  present_vars=()
  missing_vars=()

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*#!/bin/bash[[:space:]]*$ ]] && continue

    mapping="$(parse_setenv_mapping_line "$line")" || {
      err "$app_name: invalid line format in $script_path"
      exit 1
    }

    source_var="${mapping#*|}"

    if [ -z "${!source_var+x}" ] || [ -z "${!source_var}" ]; then
      missing_vars+=("$source_var")
    else
      present_vars+=("$source_var")
    fi
  done < "$script_path"

  if [ ${#present_vars[@]} -eq 0 ]; then
    if [ "$SKIP_MISSING" = true ]; then
      warn "Skipping $app_name (no variables present in secrets file)"
      continue
    fi
    err "$app_name has no variables in secrets file: ${missing_vars[*]}. Use --skip-missing to skip."
    exit 1
  fi

  if [ ${#missing_vars[@]} -gt 0 ] && [ "$SKIP_MISSING" != true ]; then
    err "$app_name has missing variables: ${missing_vars[*]}. Use --skip-missing to skip."
    exit 1
  fi

  if [ ${#missing_vars[@]} -gt 0 ]; then
    warn "$app_name: skipping missing variables (${missing_vars[*]})"
  fi

  log "Setting secrets: $app_name"
  app_failed=false
  applied_count=0

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*#!/bin/bash[[:space:]]*$ ]] && continue

    mapping="$(parse_setenv_mapping_line "$line")" || {
      err "$app_name: invalid line format in $script_path"
      app_failed=true
      break
    }

    target_env_var="${mapping%%|*}"
    source_var="${mapping#*|}"

    if [ -z "${!source_var+x}" ] || [ -z "${!source_var}" ]; then
      continue
    fi

    if cf set-env "$app_name" "$target_env_var" "${!source_var}"; then
      applied_count=$((applied_count + 1))
    else
      err "$app_name: cf set-env failed for target '$target_env_var' from source '$source_var'"
      app_failed=true
      break
    fi
  done < "$script_path"

  if [ "$app_failed" = true ]; then
    SETENV_FAILED+=("$app_name")
  elif [ "$applied_count" -gt 0 ]; then
    MODIFIED_APPS+=("$app_name")
    SETENV_SUCCEEDED+=("$app_name")
    info "$app_name set-env completed ($applied_count variable(s) applied)."
  fi
done

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
    if cf restage "$app" --strategy rolling; then
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

info "Set-env failed:    ${#SETENV_FAILED[@]}"
for app in "${SETENV_FAILED[@]}"; do
  err "  - $app"
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
elif [ "$CF_SPACE" = "prod" ]; then
  info "GitHub secrets: N/A (prod)"
else
  info "GitHub secrets: skipped (--skip-gh-secrets)"
fi

if [ ${#SETENV_FAILED[@]} -gt 0 ] || [ ${#RESTAGE_FAILED[@]} -gt 0 ] || [ "$GH_FAILED" -gt 0 ]; then
  err "Completed with failures."
  exit 1
fi

info "Done."

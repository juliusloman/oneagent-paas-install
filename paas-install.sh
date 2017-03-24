#!/bin/sh -e
ME=$(basename "$0")

die() {
  echo >&2 "${ME}: $@"
  exit 1
}

download_oneagent() {
  URL="$1"
  FILE="$2"

  # Test which of the following commands is available.
  if validate_command_exists curl; then
    curl "${URL}" > "${FILE}"
  elif validate_command_exists wget; then
    wget -O "${FILE}" "${URL}"
  fi
}

help() {
  EXIT_CODE=${1:-0}
  echo "help..."
  exit $EXIT_CODE
}

validate_api_token() {
  echo "$1" | grep -qE "^[[:alnum:]]+$" >/dev/null 2>&1
}

validate_bitness() {
  echo "$1" | grep -qE "^(all|32|64)$" >/dev/null 2>&1
}

validate_command_exists() {
  "$@" > /dev/null 2>&1
  if [ $? -eq 127 ]; then
    return 1
  fi
  return 0
}

validate_prefix_dir() {
  echo "$1" | grep -qE "^(/[[:alnum:]]+)+/?$" >/dev/null 2>&1
}

validate_technology() {
  echo "$1" | grep -qE "^(all|apache|java|nginx|nodejs|php|ruby|varnish|websphere)$" >/dev/null 2>&1
}

validate_tenant() {
  echo "$1" | grep -qE "^[[:alnum:]]{8}$" >/dev/null 2>&1
}

validate_url() {
  echo "$1" | grep -qE "^https://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|‌​]$" >/dev/null 2>&1
}

# Validate required arguments.
if [ -z "${DT_TENANT+x}" -a -z "${DT_AGENT_BASE_URL+x}" ] || [ -z "${DT_API_TOKEN+x}" ]; then
  help 1
fi

if [ ! -z "${DT_TENANT+x}" ]; then
  validate_tenant "$DT_TENANT" || die "failed to validate DT_TENANT: $DT_TENANT"
fi

if [ ! -z "${DT_API_TOKEN+x}" ]; then
  validate_api_token "$DT_API_TOKEN" || die "failed to validate DT_API_TOKEN: $DT_API_TOKEN"
fi

if [ ! -z "${DT_AGENT_BASE_URL+x}" ]; then
  validate_url "$DT_AGENT_BASE_URL" || die "failed to validate DT_AGENT_BASE_URL: $DT_AGENT_BASE_URL"
fi

# Define and validate optional arguments.
DT_AGENT_BASE_URL="${DT_AGENT_BASE_URL:-https://${DT_TENANT}.live.dynatrace.com}"
DT_AGENT_BITNESS="${DT_AGENT_BITNESS:-64}"
DT_AGENT_FOR="${DT_AGENT_FOR:-all}"
DT_AGENT_PREFIX_DIR="${DT_AGENT_PREFIX_DIR:-/var/lib}"

validate_bitness    "$DT_AGENT_BITNESS"    || die "failed to validate DT_AGENT_BITNESS: $DT_AGENT_BITNESS"
validate_prefix_dir "$DT_AGENT_PREFIX_DIR" || die "failed to validate DT_AGENT_PREFIX_DIR: $DT_AGENT_PREFIX_DIR"
validate_technology "$DT_AGENT_FOR"        || die "failed to validate DT_AGENT_FOR: $DT_AGENT_FOR"

# Define constants.
DT_AGENT_DIR="dynatrace/oneagent"
DT_AGENT_SH_FILE="/tmp/dynatrace-oneagent.sh"
DT_AGENT_URL="${DT_AGENT_URL:-${DT_AGENT_BASE_URL}/api/v1/deployment/installer/agent/unix/paas-sh/latest?Api-Token=${DT_API_TOKEN}&bitness=${DT_AGENT_BITNESS}&include=${DT_AGENT_FOR}}"

# Download and install Dynatrace OneAgent into prefix directory.
download_oneagent "${DT_AGENT_URL}" "${DT_AGENT_SH_FILE}"
sh "${DT_AGENT_SH_FILE}" "${DT_AGENT_PREFIX_DIR}"
rm -f "${DT_AGENT_SH_FILE}"
#!/bin/sh -e
ME=$(basename "$0")

help() {
  EXIT_CODE=${1:-0}
  echo "help..."
  exit $EXIT_CODE
}

die() {
  echo >&2 "${ME}: $@"
  exit 1
}

download_oneagent() {
  URL="$1"
  FILE="$2"

  # Test which of the following commands is available.
  cmd=
  if validate_command_exists curl; then
    cmd='curl -sSL'
  elif validate_command_exists wget; then
    cmd='wget -qO-'
  else
    die "failed to download Dynatrace OneAgent: neither curl nor wget are available"
  fi

  echo "Connecting to $URL"
  $cmd "${URL}" > ${FILE}
}

install_oneagent() {
  URL="$1"
  FILE="/tmp/dynatrace-oneagent.sh"
  PREFIX_DIR="$2"

  download_oneagent "${URL}" "${FILE}"
  sh "${FILE}" "${PREFIX_DIR}"
  rm -f "${FILE}"
}

install_oneagent_npm() {
  NODE_APP="$1"
  NODE_AGENT="try { require('@dynatrace/oneagent') ({ server: '$DT_AGENT_BASE_URL', apitoken: '$DT_API_TOKEN' }); } catch(err) { console.log(err.toString()); }"

  if validate_command_exists npm; then
    if [ -f "$NODE_APP" ]; then
      cd `dirname "$NODE_APP"`
      npm install @dynatrace/oneagent

      # Backup the user's application.
      cp "$NODE_APP" "$NODE_APP.bak"
      # Prepend the node agent to the user's application.
      echo "$NODE_AGENT\n\n$(cat $NODE_APP)" > "$NODE_APP"
    else
      die "failed to install Dynatrace OneAgent via npm: could not find $NODE_APP"
    fi
  else
    die "failed to install Dynatrace OneAgent via npm: npm is not available"
  fi
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
  echo "$1" | grep -qiE "^(all|apache|java|nginx|nodejs|php|ruby|varnish|websphere)$" >/dev/null 2>&1
}

validate_tenant() {
  echo "$1" | grep -qE "^[[:alnum:]]{8}$" >/dev/null 2>&1
}

validate_url() {
  echo "$1" | grep -qE "^https://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|‌​]$" >/dev/null 2>&1
}

# Validate arguments.
if [ -z "${DT_AGENT_BASE_URL+x}" -a -z "${DT_TENANT+x}" ] || [ -z "${DT_API_TOKEN+x}" ]; then
  help 1
fi

if [ ! -z "${DT_AGENT_BASE_URL+x}" ]; then
  validate_url "$DT_AGENT_BASE_URL" || die "failed to validate DT_AGENT_BASE_URL: $DT_AGENT_BASE_URL"
fi

if [ ! -z "${DT_TENANT+x}" ]; then
  validate_tenant "$DT_TENANT" || die "failed to validate DT_TENANT: $DT_TENANT"
fi

if [ ! -z "${DT_API_TOKEN+x}" ]; then
  validate_api_token "$DT_API_TOKEN" || die "failed to validate DT_API_TOKEN: $DT_API_TOKEN"
fi

DT_AGENT_BASE_URL="${DT_AGENT_BASE_URL:-https://${DT_TENANT}.live.dynatrace.com}"
DT_AGENT_BITNESS="${DT_AGENT_BITNESS:-64}"
DT_AGENT_FOR="${DT_AGENT_FOR:-all}"
DT_AGENT_PREFIX_DIR="${DT_AGENT_PREFIX_DIR:-/var/lib}"
DT_AGENT_URL="${DT_AGENT_URL:-${DT_AGENT_BASE_URL}/api/v1/deployment/installer/agent/unix/paas-sh/latest?Api-Token=${DT_API_TOKEN}&bitness=${DT_AGENT_BITNESS}&include=${DT_AGENT_FOR}}"

validate_bitness    "$DT_AGENT_BITNESS"    || die "failed to validate DT_AGENT_BITNESS: $DT_AGENT_BITNESS"
validate_prefix_dir "$DT_AGENT_PREFIX_DIR" || die "failed to validate DT_AGENT_PREFIX_DIR: $DT_AGENT_PREFIX_DIR"
validate_technology "$DT_AGENT_FOR"        || die "failed to validate DT_AGENT_FOR: $DT_AGENT_FOR"

# Download and install Dynatrace OneAgent.
if [ "$DT_AGENT_FOR" = "nodejs" ]; then
  install_oneagent_npm "$DT_AGENT_APP"
else
  install_oneagent "$DT_AGENT_URL" "$DT_AGENT_PREFIX_DIR"
fi
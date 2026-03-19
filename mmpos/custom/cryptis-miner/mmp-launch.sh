#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
if [[ -f "${SCRIPT_DIR}/mmp-external.conf" ]]; then
  source "${SCRIPT_DIR}/mmp-external.conf"
fi

EXTERNAL_NAME="${EXTERNAL_NAME:-cryptis-miner}"
EXTERNAL_VERSION="${EXTERNAL_VERSION:-1.0.1}"

MINER_BIN="${MINER_BIN:-${SCRIPT_DIR}/cryptis-miner}"
if [[ ! -x "${MINER_BIN}" ]]; then
  if command -v cryptis-miner >/dev/null 2>&1; then
    MINER_BIN="$(command -v cryptis-miner)"
  else
    echo "cryptis-miner binary not found. Expected at ${SCRIPT_DIR}/cryptis-miner or in PATH." >&2
    exit 1
  fi
fi

pool_raw=""
pool_user=""
pool_pass="x"
api_bind="${API_BIND:-127.0.0.1}"
api_port="${API_PORT:-48673}"
hive_stats_path="${HIVE_STATS_PATH:-/hiveos/stats}"
api_token="${API_TOKEN:-}"
frontend_bind="${FRONTEND_BIND:-127.0.0.1}"
frontend_port="${FRONTEND_PORT:-8943}"
worker_name="${WORKER_NAME:-$(hostname 2>/dev/null || echo worker)}"
passthrough=()

args=("$@")
index=0
while (( index < ${#args[@]} )); do
  arg="${args[index]}"
  case "${arg}" in
    --pool)
      ((index += 1))
      pool_raw="${args[index]:-}"
      ;;
    --pool=*)
      pool_raw="${arg#*=}"
      ;;
    --user)
      ((index += 1))
      pool_user="${args[index]:-}"
      ;;
    --user=*)
      pool_user="${arg#*=}"
      ;;
    --password)
      ((index += 1))
      pool_pass="${args[index]:-}"
      ;;
    --password=*)
      pool_pass="${arg#*=}"
      ;;
    --api-port)
      ((index += 1))
      api_port="${args[index]:-}"
      ;;
    --api-port=*)
      api_port="${arg#*=}"
      ;;
    --api-bind)
      ((index += 1))
      api_bind="${args[index]:-}"
      ;;
    --api-bind=*)
      api_bind="${arg#*=}"
      ;;
    --worker)
      ((index += 1))
      worker_name="${args[index]:-}"
      ;;
    --worker=*)
      worker_name="${arg#*=}"
      ;;
    mine)
      # This launcher always starts in mine mode.
      ;;
    *)
      passthrough+=("${arg}")
      ;;
  esac
  ((index += 1))
done

if [[ -z "${pool_raw}" ]]; then
  echo "Missing required --pool argument from mmpOS." >&2
  exit 1
fi

if [[ -z "${pool_user}" ]]; then
  pool_user="anonymous"
fi

if [[ "${hive_stats_path}" != /* ]]; then
  hive_stats_path="/${hive_stats_path}"
fi

pool_url="${pool_raw}"
if [[ "${pool_url}" != *"://"* ]]; then
  pool_url="stratum+tcp://${pool_url}"
fi

has_arg() {
  local needle="$1"
  local item
  for item in "${passthrough[@]}"; do
    if [[ "${item}" == "${needle}" || "${item}" == "${needle}="* ]]; then
      return 0
    fi
  done
  return 1
}

get_arg_value() {
  local needle="$1"
  local i=0
  local item=""
  while (( i < ${#passthrough[@]} )); do
    item="${passthrough[i]}"
    if [[ "${item}" == "${needle}" ]]; then
      ((i += 1))
      printf '%s' "${passthrough[i]:-}"
      return 0
    fi
    if [[ "${item}" == "${needle}="* ]]; then
      printf '%s' "${item#*=}"
      return 0
    fi
    ((i += 1))
  done
  return 1
}

runtime_state="${MMP_RUNTIME_CONFIG:-/tmp/cryptis-miner-mmpos-runtime.conf}"
{
  printf 'API_BIND=%q\n' "${api_bind}"
  printf 'API_PORT=%q\n' "${api_port}"
  printf 'API_TOKEN=%q\n' "${api_token}"
  printf 'HIVE_STATS_PATH=%q\n' "${hive_stats_path}"
} > "${runtime_state}"

command=(
  "${MINER_BIN}" mine
  --pool "${pool_url}"
  --user "${pool_user}"
  --password "${pool_pass}"
  --worker "${worker_name}"
  --api-bind "${api_bind}"
  --api-port "${api_port}"
  --hive-stats-path "${hive_stats_path}"
  --frontend-bind "${frontend_bind}"
  --frontend-port "${frontend_port}"
)

if [[ -n "${api_token}" ]] && ! has_arg --api-token; then
  command+=(--api-token "${api_token}")
fi

has_coin=0
has_hash=0
if has_arg --coin; then
  has_coin=1
fi
if has_arg --hash; then
  has_hash=1
fi

if (( has_coin == 0 && has_hash == 0 )); then
  cpu_coin="$(get_arg_value --cpu-coin || true)"
  cpu_hash="$(get_arg_value --cpu-hash || true)"
  gpu_coin="$(get_arg_value --gpu-coin || true)"
  gpu_hash="$(get_arg_value --gpu-hash || true)"

  if [[ -n "${cpu_coin}" && -n "${cpu_hash}" ]]; then
    command+=(--coin "${cpu_coin}" --hash "${cpu_hash}")
  elif [[ -n "${gpu_coin}" && -n "${gpu_hash}" ]]; then
    command+=(--coin "${gpu_coin}" --hash "${gpu_hash}")
  else
    command+=(--coin cryptix --hash ox8)
  fi
fi

command+=("${passthrough[@]}")

echo "Starting ${EXTERNAL_NAME} ${EXTERNAL_VERSION}"
echo "Command: ${command[*]}"
exec "${command[@]}"

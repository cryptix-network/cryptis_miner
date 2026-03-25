#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
if [[ -f "${SCRIPT_DIR}/mmp-external.conf" ]]; then
  source "${SCRIPT_DIR}/mmp-external.conf"
fi

trim() {
  local value="${1:-}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

trim_named_var() {
  local name="$1"
  local value="${!name-}"
  printf -v "${name}" '%s' "$(trim "${value}")"
}

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
stratum_protocol_env="${STRATUM_PROTOCOL:-${PROTO:-}}"
stratum_transport_env="${STRATUM_TRANSPORT:-${TRANSPORT:-}}"
stratum_protocol_fallback_env="${STRATUM_PROTOCOL_FALLBACK:-${PROTO_FALLBACK:-}}"
cpu_stratum_protocol_env="${CPU_STRATUM_PROTOCOL:-${CPU_PROTO:-}}"
gpu_stratum_protocol_env="${GPU_STRATUM_PROTOCOL:-${GPU_PROTO:-}}"
cpu_coin_env="${CPU_COIN:-}"
cpu_hash_env="${CPU_HASH:-}"
gpu_coin_env="${GPU_COIN:-}"
gpu_hash_env="${GPU_HASH:-}"
gpu_backend_env="${GPU_BACKEND:-}"
cuda_devices_env="${CUDA_DEVICES:-}"
opencl_devices_env="${OPENCL_DEVICES:-}"
no_cuda_env="${NO_CUDA:-0}"
no_opencl_env="${NO_OPENCL:-0}"
cuda_experimental_env="${CUDA_EXPERIMENTAL:-${CUDA_EXPERIMENTAL_ENABLED:-}}"
gpu_core_coin_env="${GPU_CORE_COIN:-}"
gpu_core_hash_env="${GPU_CORE_HASH:-}"
gpu_memory_coin_env="${GPU_MEMORY_COIN:-}"
gpu_memory_hash_env="${GPU_MEMORY_HASH:-}"
gpu_core_pool_env="${GPU_CORE_POOL:-}"
gpu_core_failover_pools_env="${GPU_CORE_FAILOVER_POOLS:-}"
gpu_core_stratum_protocol_env="${GPU_CORE_STRATUM_PROTOCOL:-${GPU_CORE_PROTO:-}}"
gpu_core_user_env="${GPU_CORE_USER:-}"
gpu_core_password_env="${GPU_CORE_PASSWORD:-}"
gpu_core_wallet_env="${GPU_CORE_WALLET:-}"
gpu_memory_pool_env="${GPU_MEMORY_POOL:-}"
gpu_memory_failover_pools_env="${GPU_MEMORY_FAILOVER_POOLS:-}"
gpu_memory_stratum_protocol_env="${GPU_MEMORY_STRATUM_PROTOCOL:-${GPU_MEMORY_PROTO:-}}"
gpu_memory_user_env="${GPU_MEMORY_USER:-}"
gpu_memory_password_env="${GPU_MEMORY_PASSWORD:-}"
gpu_memory_wallet_env="${GPU_MEMORY_WALLET:-}"
gpu_core_intensity_env="${GPU_CORE_INTENSITY:-}"
gpu_memory_intensity_env="${GPU_MEMORY_INTENSITY:-}"
passthrough=()

for scalar_var in \
  MINER_BIN \
  pool_raw pool_user api_bind api_port hive_stats_path api_token frontend_bind frontend_port worker_name \
  stratum_protocol_env stratum_transport_env stratum_protocol_fallback_env \
  cpu_stratum_protocol_env gpu_stratum_protocol_env \
  cpu_coin_env cpu_hash_env gpu_coin_env gpu_hash_env gpu_backend_env cuda_devices_env opencl_devices_env \
  no_cuda_env no_opencl_env cuda_experimental_env \
  gpu_core_coin_env gpu_core_hash_env gpu_memory_coin_env gpu_memory_hash_env \
  gpu_core_pool_env gpu_core_failover_pools_env gpu_core_stratum_protocol_env gpu_core_user_env gpu_core_wallet_env \
  gpu_memory_pool_env gpu_memory_failover_pools_env gpu_memory_stratum_protocol_env gpu_memory_user_env gpu_memory_wallet_env \
  gpu_core_intensity_env gpu_memory_intensity_env; do
  trim_named_var "${scalar_var}"
done

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

is_true() {
  local value="${1,,}"
  [[ "${value}" == "1" || "${value}" == "true" || "${value}" == "yes" || "${value}" == "on" ]]
}

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

if [[ -n "${stratum_protocol_env}" ]] && ! has_arg --stratum-protocol; then
  command+=(--stratum-protocol "${stratum_protocol_env}")
fi
if [[ -n "${stratum_transport_env}" ]] && ! has_arg --stratum-transport; then
  command+=(--stratum-transport "${stratum_transport_env}")
fi
if [[ -n "${stratum_protocol_fallback_env}" ]] && ! has_arg --stratum-protocol-fallback && ! has_arg --no-stratum-protocol-fallback; then
  if is_true "${stratum_protocol_fallback_env}"; then
    command+=(--stratum-protocol-fallback)
  else
    command+=(--no-stratum-protocol-fallback)
  fi
fi
if [[ -n "${cpu_stratum_protocol_env}" ]] && ! has_arg --cpu-stratum-protocol; then
  command+=(--cpu-stratum-protocol "${cpu_stratum_protocol_env}")
fi
if [[ -n "${gpu_stratum_protocol_env}" ]] && ! has_arg --gpu-stratum-protocol; then
  command+=(--gpu-stratum-protocol "${gpu_stratum_protocol_env}")
fi

if [[ -n "${cpu_coin_env}" ]] && ! has_arg --cpu-coin; then
  command+=(--cpu-coin "${cpu_coin_env}")
fi
if [[ -n "${cpu_hash_env}" ]] && ! has_arg --cpu-hash; then
  command+=(--cpu-hash "${cpu_hash_env}")
fi
if [[ -n "${gpu_coin_env}" ]] && ! has_arg --gpu-coin; then
  command+=(--gpu-coin "${gpu_coin_env}")
fi
if [[ -n "${gpu_hash_env}" ]] && ! has_arg --gpu-hash; then
  command+=(--gpu-hash "${gpu_hash_env}")
fi
if [[ -n "${gpu_backend_env}" ]] && ! has_arg --gpu-backend; then
  command+=(--gpu-backend "${gpu_backend_env}")
fi
if [[ -n "${cuda_devices_env}" ]] && ! has_arg --cuda-devices; then
  command+=(--cuda-devices "${cuda_devices_env}")
fi
if [[ -n "${opencl_devices_env}" ]] && ! has_arg --opencl-devices; then
  command+=(--opencl-devices "${opencl_devices_env}")
fi
if is_true "${no_cuda_env}" && ! has_arg --no-cuda; then
  command+=(--no-cuda)
fi
if is_true "${no_opencl_env}" && ! has_arg --no-opencl; then
  command+=(--no-opencl)
fi
if ! has_arg --cuda-experimental && ! is_true "${no_cuda_env}" && is_true "${cuda_experimental_env}"; then
  command+=(--cuda-experimental)
fi

if [[ -n "${gpu_core_coin_env}" ]] && ! has_arg --gpu-core-coin; then
  command+=(--gpu-core-coin "${gpu_core_coin_env}")
fi
if [[ -n "${gpu_core_hash_env}" ]] && ! has_arg --gpu-core-hash; then
  command+=(--gpu-core-hash "${gpu_core_hash_env}")
fi
if [[ -n "${gpu_memory_coin_env}" ]] && ! has_arg --gpu-memory-coin; then
  command+=(--gpu-memory-coin "${gpu_memory_coin_env}")
fi
if [[ -n "${gpu_memory_hash_env}" ]] && ! has_arg --gpu-memory-hash; then
  command+=(--gpu-memory-hash "${gpu_memory_hash_env}")
fi
if [[ -n "${gpu_core_pool_env}" ]] && ! has_arg --gpu-core-pool; then
  command+=(--gpu-core-pool "${gpu_core_pool_env}")
fi
if [[ -n "${gpu_core_failover_pools_env}" ]] && ! has_arg --gpu-core-failover-pools; then
  command+=(--gpu-core-failover-pools "${gpu_core_failover_pools_env}")
fi
if [[ -n "${gpu_core_stratum_protocol_env}" ]] && ! has_arg --gpu-core-stratum-protocol; then
  command+=(--gpu-core-stratum-protocol "${gpu_core_stratum_protocol_env}")
fi
if [[ -n "${gpu_core_user_env}" ]] && ! has_arg --gpu-core-user; then
  command+=(--gpu-core-user "${gpu_core_user_env}")
fi
if [[ -n "${gpu_core_password_env}" ]] && ! has_arg --gpu-core-password; then
  command+=(--gpu-core-password "${gpu_core_password_env}")
fi
if [[ -n "${gpu_core_wallet_env}" ]] && ! has_arg --gpu-core-wallet; then
  command+=(--gpu-core-wallet "${gpu_core_wallet_env}")
fi
if [[ -n "${gpu_memory_pool_env}" ]] && ! has_arg --gpu-memory-pool; then
  command+=(--gpu-memory-pool "${gpu_memory_pool_env}")
fi
if [[ -n "${gpu_memory_failover_pools_env}" ]] && ! has_arg --gpu-memory-failover-pools; then
  command+=(--gpu-memory-failover-pools "${gpu_memory_failover_pools_env}")
fi
if [[ -n "${gpu_memory_stratum_protocol_env}" ]] && ! has_arg --gpu-memory-stratum-protocol; then
  command+=(--gpu-memory-stratum-protocol "${gpu_memory_stratum_protocol_env}")
fi
if [[ -n "${gpu_memory_user_env}" ]] && ! has_arg --gpu-memory-user; then
  command+=(--gpu-memory-user "${gpu_memory_user_env}")
fi
if [[ -n "${gpu_memory_password_env}" ]] && ! has_arg --gpu-memory-password; then
  command+=(--gpu-memory-password "${gpu_memory_password_env}")
fi
if [[ -n "${gpu_memory_wallet_env}" ]] && ! has_arg --gpu-memory-wallet; then
  command+=(--gpu-memory-wallet "${gpu_memory_wallet_env}")
fi
if [[ -n "${gpu_core_intensity_env}" ]] && ! has_arg --gpu-core-intensity; then
  command+=(--gpu-core-intensity "${gpu_core_intensity_env}")
fi
if [[ -n "${gpu_memory_intensity_env}" ]] && ! has_arg --gpu-memory-intensity; then
  command+=(--gpu-memory-intensity "${gpu_memory_intensity_env}")
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
  gpu_core_coin="$(get_arg_value --gpu-core-coin || true)"
  gpu_core_hash="$(get_arg_value --gpu-core-hash || true)"
  gpu_memory_coin="$(get_arg_value --gpu-memory-coin || true)"
  gpu_memory_hash="$(get_arg_value --gpu-memory-hash || true)"

  if [[ -n "${cpu_coin}" && -n "${cpu_hash}" ]]; then
    command+=(--coin "${cpu_coin}" --hash "${cpu_hash}")
  elif [[ -n "${gpu_core_coin}" && -n "${gpu_core_hash}" ]]; then
    command+=(--coin "${gpu_core_coin}" --hash "${gpu_core_hash}")
  elif [[ -n "${gpu_memory_coin}" && -n "${gpu_memory_hash}" ]]; then
    command+=(--coin "${gpu_memory_coin}" --hash "${gpu_memory_hash}")
  elif [[ -n "${gpu_coin}" && -n "${gpu_hash}" ]]; then
    command+=(--coin "${gpu_coin}" --hash "${gpu_hash}")
  else
    command+=(--coin cryptix --hash ox8)
  fi
fi

effective_gpu_hash="$(get_arg_value --gpu-hash || true)"
if [[ -z "${effective_gpu_hash}" ]]; then
  effective_gpu_hash="${gpu_hash_env}"
fi
effective_gpu_hash="$(trim "${effective_gpu_hash}")"
effective_gpu_core_hash="$(get_arg_value --gpu-core-hash || true)"
if [[ -z "${effective_gpu_core_hash}" ]]; then
  effective_gpu_core_hash="${gpu_core_hash_env}"
fi
effective_gpu_core_hash="$(trim "${effective_gpu_core_hash}")"
effective_gpu_memory_hash="$(get_arg_value --gpu-memory-hash || true)"
if [[ -z "${effective_gpu_memory_hash}" ]]; then
  effective_gpu_memory_hash="${gpu_memory_hash_env}"
fi
effective_gpu_memory_hash="$(trim "${effective_gpu_memory_hash}")"
if [[ -n "${effective_gpu_memory_hash}" ]]; then
  lane_core_hash="${effective_gpu_core_hash:-${effective_gpu_hash:-$(get_arg_value --hash || true)}}"
  lane_core_hash="$(trim "${lane_core_hash}")"
  lane_core_hash="${lane_core_hash,,}"
  lane_memory_hash="${effective_gpu_memory_hash,,}"
  if [[ "${lane_memory_hash}" != "autolykosv2" || ( "${lane_core_hash}" != "ox8" && "${lane_core_hash}" != "hoohash" ) ]]; then
    echo "Unsupported dual/triple lane hash pair: supported pairs are gpu-core='ox8'+gpu-memory='autolykosv2' and gpu-core='hoohash'+gpu-memory='autolykosv2'." >&2
    exit 1
  fi
  if [[ "${lane_core_hash}" == "hoohash" ]] && is_true "${no_opencl_env}"; then
    echo "Unsupported dual/triple lane hash pair gpu-core='hoohash'+gpu-memory='autolykosv2': this pair is currently OpenCL-only, but --no-opencl/NO_OPENCL is active." >&2
    exit 1
  fi
fi

command+=("${passthrough[@]}")

echo "Starting ${EXTERNAL_NAME} ${EXTERNAL_VERSION}"
echo "Command: ${command[*]}"
exec "${command[@]}"

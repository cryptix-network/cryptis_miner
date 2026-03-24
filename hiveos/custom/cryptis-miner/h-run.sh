#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/h-manifest.conf"

"${SCRIPT_DIR}/h-config.sh"

# shellcheck disable=SC1090
source "${CUSTOM_CONFIG_FILENAME}"

mkdir -p "$(dirname "${CUSTOM_LOG_BASENAME}")"
miner_log_file="${CUSTOM_LOG_BASENAME}.log"

command=(
  "${CUSTOM_BIN}" mine
  --pool "${POOL_URL}"
  --user "${POOL_USER}"
  --password "${POOL_PASS}"
  --worker "${WORKER_NAME_VALUE}"
  --coin "${COIN}"
  --hash "${HASH_NAME}"
  --stratum-protocol "${STRATUM_PROTOCOL}"
  --stratum-transport "${STRATUM_TRANSPORT}"
  --api-bind "${API_BIND}"
  --api-port "${API_PORT}"
  --hive-stats-path "${HIVE_STATS_PATH}"
  --frontend-bind "${FRONTEND_BIND}"
  --frontend-port "${FRONTEND_PORT}"
  --log-file "${miner_log_file}"
)

is_true() {
  local value="${1,,}"
  [[ "${value}" == "1" || "${value}" == "true" || "${value}" == "yes" || "${value}" == "on" ]]
}

if [[ -n "${API_TOKEN:-}" ]]; then
  command+=(--api-token "${API_TOKEN}")
fi

if [[ -n "${STRATUM_PROTOCOL_FALLBACK:-}" ]]; then
  if is_true "${STRATUM_PROTOCOL_FALLBACK}"; then
    command+=(--stratum-protocol-fallback)
  else
    command+=(--no-stratum-protocol-fallback)
  fi
fi

effective_cpu_user="${CPU_USER:-}"
effective_gpu_user="${GPU_USER:-}"
effective_gpu_core_user="${GPU_CORE_USER:-}"
effective_gpu_memory_user="${GPU_MEMORY_USER:-}"
if [[ -z "${effective_cpu_user}" && -n "${CPU_WALLET:-}" && -n "${POOL_USER:-}" ]]; then
  if [[ "${POOL_USER,,}" != "anonymous" ]]; then
    effective_cpu_user="${CPU_WALLET}"
  fi
fi
if [[ -z "${effective_gpu_user}" && -n "${GPU_WALLET:-}" && -n "${POOL_USER:-}" ]]; then
  if [[ "${POOL_USER,,}" != "anonymous" ]]; then
    effective_gpu_user="${GPU_WALLET}"
  fi
fi
if [[ -z "${effective_gpu_core_user}" && -n "${GPU_CORE_WALLET:-}" && -n "${POOL_USER:-}" ]]; then
  if [[ "${POOL_USER,,}" != "anonymous" ]]; then
    effective_gpu_core_user="${GPU_CORE_WALLET}"
  fi
fi
if [[ -z "${effective_gpu_memory_user}" && -n "${GPU_MEMORY_WALLET:-}" && -n "${POOL_USER:-}" ]]; then
  if [[ "${POOL_USER,,}" != "anonymous" ]]; then
    effective_gpu_memory_user="${GPU_MEMORY_WALLET}"
  fi
fi

if is_true "${NO_CPU:-0}"; then
  command+=(--no-cpu)
fi

if is_true "${NO_GPU:-0}"; then
  command+=(--no-gpu)
fi

if [[ -n "${GPU_DEVICES:-}" ]]; then
  command+=(--gpu-devices "${GPU_DEVICES}")
fi

if [[ -n "${CUDA_DEVICES:-}" ]]; then
  command+=(--cuda-devices "${CUDA_DEVICES}")
fi

if [[ -n "${OPENCL_DEVICES:-}" ]]; then
  command+=(--opencl-devices "${OPENCL_DEVICES}")
fi

if [[ -n "${GPU_BACKEND:-}" ]]; then
  command+=(--gpu-backend "${GPU_BACKEND}")
fi
if [[ -n "${CUDA_EXPERIMENTAL:-}" ]] && is_true "${CUDA_EXPERIMENTAL}"; then
  command+=(--cuda-experimental)
fi

if [[ -n "${CPU_COIN:-}" ]]; then
  command+=(--cpu-coin "${CPU_COIN}")
fi

if [[ -n "${CPU_HASH:-}" ]]; then
  command+=(--cpu-hash "${CPU_HASH}")
fi

if [[ -n "${GPU_COIN:-}" ]]; then
  command+=(--gpu-coin "${GPU_COIN}")
fi

if [[ -n "${GPU_HASH:-}" ]]; then
  command+=(--gpu-hash "${GPU_HASH}")
fi

if [[ -n "${GPU_CORE_COIN:-}" ]]; then
  command+=(--gpu-core-coin "${GPU_CORE_COIN}")
fi

if [[ -n "${GPU_CORE_HASH:-}" ]]; then
  command+=(--gpu-core-hash "${GPU_CORE_HASH}")
fi

if [[ -n "${GPU_MEMORY_COIN:-}" ]]; then
  command+=(--gpu-memory-coin "${GPU_MEMORY_COIN}")
fi

if [[ -n "${GPU_MEMORY_HASH:-}" ]]; then
  command+=(--gpu-memory-hash "${GPU_MEMORY_HASH}")
fi

if [[ -n "${RANDOMX_HUGEPAGES:-}" ]]; then
  command+=(--randomx-hugepages "${RANDOMX_HUGEPAGES}")
fi

if [[ -n "${RANDOMX_MSR:-}" ]]; then
  command+=(--randomx-msr "${RANDOMX_MSR}")
fi

if [[ -n "${CPU_POOL:-}" ]]; then
  command+=(--cpu-pool "${CPU_POOL}")
fi

if [[ -n "${CPU_FAILOVER_POOLS:-}" ]]; then
  command+=(--cpu-failover-pools "${CPU_FAILOVER_POOLS}")
fi

if [[ -n "${CPU_STRATUM_PROTOCOL:-}" ]]; then
  command+=(--cpu-stratum-protocol "${CPU_STRATUM_PROTOCOL}")
fi

if [[ -n "${effective_cpu_user:-}" ]]; then
  command+=(--cpu-user "${effective_cpu_user}")
fi

if [[ -n "${CPU_PASSWORD:-}" ]]; then
  command+=(--cpu-password "${CPU_PASSWORD}")
fi

if [[ -n "${CPU_WALLET:-}" ]]; then
  command+=(--cpu-wallet "${CPU_WALLET}")
fi

if [[ -n "${GPU_POOL:-}" ]]; then
  command+=(--gpu-pool "${GPU_POOL}")
fi

if [[ -n "${GPU_FAILOVER_POOLS:-}" ]]; then
  command+=(--gpu-failover-pools "${GPU_FAILOVER_POOLS}")
fi

if [[ -n "${GPU_STRATUM_PROTOCOL:-}" ]]; then
  command+=(--gpu-stratum-protocol "${GPU_STRATUM_PROTOCOL}")
fi

if [[ -n "${effective_gpu_user:-}" ]]; then
  command+=(--gpu-user "${effective_gpu_user}")
fi

if [[ -n "${GPU_PASSWORD:-}" ]]; then
  command+=(--gpu-password "${GPU_PASSWORD}")
fi

if [[ -n "${GPU_WALLET:-}" ]]; then
  command+=(--gpu-wallet "${GPU_WALLET}")
fi

if [[ -n "${GPU_CORE_POOL:-}" ]]; then
  command+=(--gpu-core-pool "${GPU_CORE_POOL}")
fi

if [[ -n "${GPU_CORE_FAILOVER_POOLS:-}" ]]; then
  command+=(--gpu-core-failover-pools "${GPU_CORE_FAILOVER_POOLS}")
fi

if [[ -n "${GPU_CORE_STRATUM_PROTOCOL:-}" ]]; then
  command+=(--gpu-core-stratum-protocol "${GPU_CORE_STRATUM_PROTOCOL}")
fi

if [[ -n "${effective_gpu_core_user:-}" ]]; then
  command+=(--gpu-core-user "${effective_gpu_core_user}")
fi

if [[ -n "${GPU_CORE_PASSWORD:-}" ]]; then
  command+=(--gpu-core-password "${GPU_CORE_PASSWORD}")
fi

if [[ -n "${GPU_CORE_WALLET:-}" ]]; then
  command+=(--gpu-core-wallet "${GPU_CORE_WALLET}")
fi

if [[ -n "${GPU_MEMORY_POOL:-}" ]]; then
  command+=(--gpu-memory-pool "${GPU_MEMORY_POOL}")
fi

if [[ -n "${GPU_MEMORY_FAILOVER_POOLS:-}" ]]; then
  command+=(--gpu-memory-failover-pools "${GPU_MEMORY_FAILOVER_POOLS}")
fi

if [[ -n "${GPU_MEMORY_STRATUM_PROTOCOL:-}" ]]; then
  command+=(--gpu-memory-stratum-protocol "${GPU_MEMORY_STRATUM_PROTOCOL}")
fi

if [[ -n "${effective_gpu_memory_user:-}" ]]; then
  command+=(--gpu-memory-user "${effective_gpu_memory_user}")
fi

if [[ -n "${GPU_MEMORY_PASSWORD:-}" ]]; then
  command+=(--gpu-memory-password "${GPU_MEMORY_PASSWORD}")
fi

if [[ -n "${GPU_MEMORY_WALLET:-}" ]]; then
  command+=(--gpu-memory-wallet "${GPU_MEMORY_WALLET}")
fi

if [[ -n "${INTENSITY:-}" ]]; then
  command+=(--intensity "${INTENSITY}")
fi

if [[ -n "${INTENSITY_MIN:-}" ]]; then
  command+=(--intensity-min "${INTENSITY_MIN}")
fi

if [[ -n "${INTENSITY_MAX:-}" ]]; then
  command+=(--intensity-max "${INTENSITY_MAX}")
fi

if [[ -n "${CPU_INTENSITY:-}" ]]; then
  command+=(--cpu-intensity "${CPU_INTENSITY}")
fi

if [[ -n "${GPU_INTENSITY:-}" ]]; then
  command+=(--gpu-intensity "${GPU_INTENSITY}")
fi

if [[ -n "${GPU_CORE_INTENSITY:-}" ]]; then
  command+=(--gpu-core-intensity "${GPU_CORE_INTENSITY}")
fi

if [[ -n "${GPU_MEMORY_INTENSITY:-}" ]]; then
  command+=(--gpu-memory-intensity "${GPU_MEMORY_INTENSITY}")
fi

if [[ -n "${POOL_RETRY_COUNT:-}" ]]; then
  command+=(--pool-retry-count "${POOL_RETRY_COUNT}")
fi

if [[ -n "${POOL_RETRY_DELAY_MS:-}" ]]; then
  command+=(--pool-retry-delay-ms "${POOL_RETRY_DELAY_MS}")
fi

if [[ -n "${POOL_CONNECT_TIMEOUT_MS:-}" ]]; then
  command+=(--pool-connect-timeout-ms "${POOL_CONNECT_TIMEOUT_MS}")
fi

if [[ -n "${POOL_TLS_TIMEOUT_MS:-}" ]]; then
  command+=(--pool-tls-timeout-ms "${POOL_TLS_TIMEOUT_MS}")
fi

if [[ -n "${POOL_REQUEST_TIMEOUT_MS:-}" ]]; then
  command+=(--pool-request-timeout-ms "${POOL_REQUEST_TIMEOUT_MS}")
fi

if [[ -n "${POOL_JOB_CHANNEL_SIZE:-}" ]]; then
  command+=(--pool-job-channel-size "${POOL_JOB_CHANNEL_SIZE}")
fi

if [[ -n "${JOB_RECV_TIMEOUT_MS:-}" ]]; then
  command+=(--job-recv-timeout-ms "${JOB_RECV_TIMEOUT_MS}")
fi

if [[ -n "${STATS_INTERVAL_MS:-}" ]]; then
  command+=(--stats-interval-ms "${STATS_INTERVAL_MS}")
fi

if [[ -n "${GPU_STATUS_BOARD_INTERVAL_MS:-}" ]]; then
  command+=(--gpu-status-board-interval-ms "${GPU_STATUS_BOARD_INTERVAL_MS}")
fi

if [[ -n "${HYBRID_CPU_RESERVE_MIN_CORES:-}" ]]; then
  command+=(--hybrid-cpu-reserve-min-cores "${HYBRID_CPU_RESERVE_MIN_CORES}")
fi

if [[ -n "${HYBRID_CPU_RESERVE_MAX_CORES:-}" ]]; then
  command+=(--hybrid-cpu-reserve-max-cores "${HYBRID_CPU_RESERVE_MAX_CORES}")
fi

if [[ -n "${HYBRID_CPU_RESERVE_GPU_THRESHOLD:-}" ]]; then
  command+=(--hybrid-cpu-reserve-gpu-threshold "${HYBRID_CPU_RESERVE_GPU_THRESHOLD}")
fi

if [[ -n "${CPU_ONLY_RESERVE_SYSTEM_CORE:-}" ]]; then
  if is_true "${CPU_ONLY_RESERVE_SYSTEM_CORE}"; then
    command+=(--cpu-only-reserve-system-core)
  else
    command+=(--no-cpu-only-reserve-system-core)
  fi
fi

if [[ -n "${CPU_ONLY_RESERVED_CORES:-}" ]]; then
  command+=(--cpu-only-reserved-cores "${CPU_ONLY_RESERVED_CORES}")
fi

if [[ -n "${SHARE_QUEUE_CAPACITY:-}" ]]; then
  command+=(--share-queue-capacity "${SHARE_QUEUE_CAPACITY}")
fi

if [[ -n "${SHARE_SUBMIT_RATE:-}" ]]; then
  command+=(--share-submit-rate "${SHARE_SUBMIT_RATE}")
fi

if [[ -n "${SHARE_SUBMIT_BURST:-}" ]]; then
  command+=(--share-submit-burst "${SHARE_SUBMIT_BURST}")
fi

if [[ -n "${RECENT_JOB_MAX_IDS:-}" ]]; then
  command+=(--recent-job-max-ids "${RECENT_JOB_MAX_IDS}")
fi

if [[ -n "${RECENT_JOB_MAX_AGE_MS:-}" ]]; then
  command+=(--recent-job-max-age-ms "${RECENT_JOB_MAX_AGE_MS}")
fi

if [[ -n "${GPU_CPU_VERIFY:-}" ]]; then
  command+=(--gpu-cpu-verify "${GPU_CPU_VERIFY}")
fi

if [[ -n "${GPU_OPENCL_MAD_ENABLE:-}" ]]; then
  command+=(--gpu-opencl-mad-enable "${GPU_OPENCL_MAD_ENABLE}")
fi

if [[ -n "${GPU_OPENCL_NATIVE_MATH_ENABLE:-}" ]]; then
  command+=(--gpu-opencl-native-math-enable "${GPU_OPENCL_NATIVE_MATH_ENABLE}")
fi

if [[ -n "${GPU_OPENCL_ACCURACY_BOOST:-}" ]]; then
  command+=(--gpu-opencl-accuracy-boost "${GPU_OPENCL_ACCURACY_BOOST}")
fi

if [[ -n "${GPU_STRICT_JOB:-}" ]]; then
  command+=(--gpu-strict-job "${GPU_STRICT_JOB}")
fi

if [[ -n "${GPU_RECENT_JOB_MAX_IDS:-}" ]]; then
  command+=(--gpu-recent-job-max-ids "${GPU_RECENT_JOB_MAX_IDS}")
fi

if [[ -n "${GPU_RECENT_JOB_MAX_AGE_MS:-}" ]]; then
  command+=(--gpu-recent-job-max-age-ms "${GPU_RECENT_JOB_MAX_AGE_MS}")
fi

if [[ -n "${TASK_DRAIN_TIMEOUT_MS:-}" ]]; then
  command+=(--task-drain-timeout-ms "${TASK_DRAIN_TIMEOUT_MS}")
fi

if [[ -n "${SHUTDOWN_POLL_MS:-}" ]]; then
  command+=(--shutdown-poll-ms "${SHUTDOWN_POLL_MS}")
fi

if [[ -n "${RECONNECT_MIN_DELAY_MS:-}" ]]; then
  command+=(--reconnect-min-delay-ms "${RECONNECT_MIN_DELAY_MS}")
fi

if [[ -n "${RECONNECT_BACKOFF_MAX_POWER:-}" ]]; then
  command+=(--reconnect-backoff-max-power "${RECONNECT_BACKOFF_MAX_POWER}")
fi

if [[ -n "${WORKER_IDLE_SLEEP_MS:-}" ]]; then
  command+=(--worker-idle-sleep-ms "${WORKER_IDLE_SLEEP_MS}")
fi

if [[ -n "${WORKER_RECV_TIMEOUT_MS:-}" ]]; then
  command+=(--worker-recv-timeout-ms "${WORKER_RECV_TIMEOUT_MS}")
fi

if [[ -n "${WORKER_MAX_SLICE_MS:-}" ]]; then
  command+=(--worker-max-slice-ms "${WORKER_MAX_SLICE_MS}")
fi

if [[ -n "${WORKER_SLICE_CHECK_INTERVAL:-}" ]]; then
  command+=(--worker-slice-check-interval "${WORKER_SLICE_CHECK_INTERVAL}")
fi

if [[ -n "${WORKER_ACTIVE_POLL_INTERVAL:-}" ]]; then
  command+=(--worker-active-poll-interval "${WORKER_ACTIVE_POLL_INTERVAL}")
fi

if [[ -n "${WORKER_STATS_FLUSH_THRESHOLD:-}" ]]; then
  command+=(--worker-stats-flush-threshold "${WORKER_STATS_FLUSH_THRESHOLD}")
fi

if [[ -n "${WORKER_STATS_FLUSH_INTERVAL_MS:-}" ]]; then
  command+=(--worker-stats-flush-interval-ms "${WORKER_STATS_FLUSH_INTERVAL_MS}")
fi

if [[ -n "${CPU_BATCH_BASE:-}" ]]; then
  command+=(--cpu-batch-base "${CPU_BATCH_BASE}")
fi

if [[ -n "${CPU_BATCH_MIN:-}" ]]; then
  command+=(--cpu-batch-min "${CPU_BATCH_MIN}")
fi

if [[ -n "${CPU_BATCH_MAX:-}" ]]; then
  command+=(--cpu-batch-max "${CPU_BATCH_MAX}")
fi

if [[ -n "${CPU_BATCH_SIZE:-}" ]]; then
  command+=(--cpu-batch-size "${CPU_BATCH_SIZE}")
fi

if [[ -n "${GPU_BATCH_BASE:-}" ]]; then
  command+=(--gpu-batch-base "${GPU_BATCH_BASE}")
fi

if [[ -n "${GPU_BATCH_MIN:-}" ]]; then
  command+=(--gpu-batch-min "${GPU_BATCH_MIN}")
fi

if [[ -n "${GPU_BATCH_MAX:-}" ]]; then
  command+=(--gpu-batch-max "${GPU_BATCH_MAX}")
fi

if [[ -n "${OPENCL_BATCH_SIZE:-}" ]]; then
  command+=(--opencl-batch-size "${OPENCL_BATCH_SIZE}")
fi

if [[ -n "${OPENCL_LOCAL_WORK_SIZE:-}" ]]; then
  command+=(--opencl-local-work-size "${OPENCL_LOCAL_WORK_SIZE}")
fi

if [[ -n "${AUTOLYKOS_BLOCK_SIZE:-}" ]]; then
  command+=(--autolykos-block-size "${AUTOLYKOS_BLOCK_SIZE}")
fi

if [[ -n "${CUDA_BATCH_SIZE:-}" ]]; then
  command+=(--cuda-batch-size "${CUDA_BATCH_SIZE}")
fi

if [[ -n "${CUDA_BLOCK_SIZE:-}" ]]; then
  command+=(--cuda-block-size "${CUDA_BLOCK_SIZE}")
fi

if [[ -n "${CPU_AUTOTUNE_PROBE_MS:-}" ]]; then
  command+=(--cpu-autotune-probe-ms "${CPU_AUTOTUNE_PROBE_MS}")
fi

if [[ -n "${GPU_AUTOTUNE_ROUNDS:-}" ]]; then
  command+=(--gpu-autotune-rounds "${GPU_AUTOTUNE_ROUNDS}")
fi

if [[ -n "${OPENCL_AUTOTUNE:-}" ]]; then
  if is_true "${OPENCL_AUTOTUNE}"; then
    command+=(--opencl-autotune)
  else
    command+=(--no-opencl-autotune)
  fi
fi

if [[ -n "${CUDA_AUTOTUNE:-}" ]]; then
  if is_true "${CUDA_AUTOTUNE}"; then
    command+=(--cuda-autotune)
  else
    command+=(--no-cuda-autotune)
  fi
fi

if [[ -n "${CPU_AUTOTUNE:-}" ]]; then
  if is_true "${CPU_AUTOTUNE}"; then
    command+=(--cpu-autotune)
  else
    command+=(--no-cpu-autotune)
  fi
fi

if is_true "${NO_CUDA:-0}"; then
  command+=(--no-cuda)
fi

if is_true "${NO_OPENCL:-0}"; then
  command+=(--no-opencl)
fi

if is_true "${DISABLE_GPU_AMD:-0}"; then
  command+=(--disable-gpu-amd)
fi

if is_true "${DISABLE_GPU_NVIDIA:-0}"; then
  command+=(--disable-gpu-nvidia)
fi

if is_true "${DISABLE_GPU_INTEL:-0}"; then
  command+=(--disable-gpu-intel)
fi

if is_true "${HIVE_STATS_DISABLED:-0}"; then
  command+=(--hive-stats-disabled)
fi

if is_true "${FRONTEND_DISABLED:-0}"; then
  command+=(--frontend-disabled)
fi

if is_true "${FRONTEND_LOGS_DISABLED:-0}"; then
  command+=(--frontend-logs-disabled)
fi

if is_true "${FRONTEND_PASSWORD_ENABLED:-0}"; then
  command+=(--frontend-password-enabled)
fi

if [[ -n "${FRONTEND_PASSWORD:-}" ]]; then
  command+=(--frontend-password "${FRONTEND_PASSWORD}")
fi

if [[ -n "${FRONTEND_RATE_LIMIT_PER_MINUTE:-}" ]]; then
  command+=(--frontend-rate-limit-per-minute "${FRONTEND_RATE_LIMIT_PER_MINUTE}")
fi

if [[ -n "${BENCH_REPORT:-}" ]]; then
  if is_true "${BENCH_REPORT}"; then
    command+=(--bench-report)
  else
    command+=(--no-bench-report)
  fi
fi

if [[ -n "${BENCH_REPORT_INTERVAL_SEC:-}" ]]; then
  command+=(--bench-report-interval-sec "${BENCH_REPORT_INTERVAL_SEC}")
fi

if [[ -n "${BENCH_REPORT_ID_FILE:-}" ]]; then
  command+=(--bench-report-id-file "${BENCH_REPORT_ID_FILE}")
fi

if [[ -n "${BENCH_REPORT_API_KEY:-}" ]]; then
  command+=(--bench-report-api-key "${BENCH_REPORT_API_KEY}")
fi

if [[ -n "${BENCH_INSIGHTS:-}" ]]; then
  if is_true "${BENCH_INSIGHTS}"; then
    command+=(--bench-insights)
  else
    command+=(--no-bench-insights)
  fi
fi

if [[ -n "${EXTRA_ARGS:-}" ]]; then
  # Split custom CLI args from Hive custom user config.
  # shellcheck disable=SC2206
  extra_args_array=(${EXTRA_ARGS})
  command+=("${extra_args_array[@]}")
fi

echo "Starting ${CUSTOM_NAME} ${CUSTOM_VERSION}"
echo "Command: ${command[*]}"
exec "${command[@]}"

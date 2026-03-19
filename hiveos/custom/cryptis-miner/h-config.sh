#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/h-manifest.conf"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

kv_from_csv() {
  local csv="$1"
  local key="$2"
  local part candidate_key part_value
  local current_key=""
  local current_value=""

  IFS=',' read -r -a parts <<< "${csv}"
  for part in "${parts[@]}"; do
    part="$(trim "${part}")"
    if [[ -z "${part}" ]]; then
      continue
    fi

    if [[ "${part}" == *:* ]]; then
      candidate_key="$(trim "${part%%:*}")"
      if [[ "${candidate_key}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && is_known_csv_key "${candidate_key}"; then
        if [[ -n "${current_key}" && "${current_key^^}" == "${key^^}" ]]; then
          printf '%s' "$(trim "${current_value}")"
          return 0
        fi
        current_key="${candidate_key}"
        current_value="$(trim "${part#*:}")"
        continue
      fi
    fi

    if [[ -n "${current_key}" ]]; then
      part_value="$(trim "${part}")"
      if [[ -n "${current_value}" ]]; then
        current_value="${current_value},${part_value}"
      else
        current_value="${part_value}"
      fi
    fi
  done

  if [[ -n "${current_key}" && "${current_key^^}" == "${key^^}" ]]; then
    printf '%s' "$(trim "${current_value}")"
    return 0
  fi

  return 1
}

is_known_csv_key() {
  case "${1^^}" in
    "POOL"|"TEMPLATE"|"PASS"|"PROTO"|"PROTO_FALLBACK"|"STRATUM_PROTOCOL_FALLBACK"|"TRANSPORT"|"ALGO"|"COIN"|"HASH"|"RANDOMX_HUGEPAGES"|"RANDOMX_MSR"|"CPU_COIN"|"CPU_HASH"|"GPU_COIN"|"GPU_HASH"|"CPU_POOL"|"CPU_FAILOVER_POOLS"|"CPU_PROTO"|"CPU_STRATUM_PROTOCOL"|"CPU_USER"|"CPU_PASSWORD"|"CPU_WALLET"|"GPU_POOL"|"GPU_FAILOVER_POOLS"|"GPU_PROTO"|"GPU_STRATUM_PROTOCOL"|"GPU_USER"|"GPU_PASSWORD"|"GPU_WALLET"|"WORKER"|"API_BIND"|"API_PORT"|"API_TOKEN"|"FRONTEND_BIND"|"FRONTEND_PORT"|"FRONTEND_DISABLED"|"FRONTEND_LOGS_DISABLED"|"FRONTEND_PASSWORD_ENABLED"|"FRONTEND_PASSWORD"|"FRONTEND_RATE_LIMIT_PER_MINUTE"|"BENCH_REPORT"|"BENCH_REPORT_INTERVAL_SEC"|"BENCH_REPORT_ID_FILE"|"BENCH_REPORT_API_KEY"|"BENCH_INSIGHTS"|"NO_CPU"|"NO_GPU"|"GPU_DEVICES"|"CUDA_DEVICES"|"OPENCL_DEVICES"|"GPU_BACKEND"|"INTENSITY"|"INTENSITY_MIN"|"INTENSITY_MAX"|"CPU_INTENSITY"|"GPU_INTENSITY"|"NO_CUDA"|"NO_OPENCL"|"DISABLE_GPU_AMD"|"DISABLE_GPU_NVIDIA"|"DISABLE_GPU_INTEL"|"RETRY_COUNT"|"RETRY_DELAY_MS"|"CONNECT_TIMEOUT_MS"|"TLS_TIMEOUT_MS"|"REQUEST_TIMEOUT_MS"|"JOB_CHANNEL_SIZE"|"JOB_RECV_TIMEOUT_MS"|"STATS_INTERVAL_MS"|"SHARE_QUEUE_CAPACITY"|"SHARE_SUBMIT_RATE"|"SHARE_SUBMIT_BURST"|"RECENT_JOB_MAX_IDS"|"RECENT_JOB_MAX_AGE_MS"|"GPU_STATUS_BOARD_INTERVAL_MS"|"HYBRID_CPU_RESERVE_MIN_CORES"|"HYBRID_CPU_RESERVE_MAX_CORES"|"HYBRID_CPU_RESERVE_GPU_THRESHOLD"|"TASK_DRAIN_TIMEOUT_MS"|"SHUTDOWN_POLL_MS"|"RECONNECT_MIN_DELAY_MS"|"RECONNECT_BACKOFF_MAX_POWER"|"WORKER_IDLE_SLEEP_MS"|"WORKER_RECV_TIMEOUT_MS"|"WORKER_MAX_SLICE_MS"|"WORKER_SLICE_CHECK_INTERVAL"|"WORKER_ACTIVE_POLL_INTERVAL"|"WORKER_STATS_FLUSH_THRESHOLD"|"WORKER_STATS_FLUSH_INTERVAL_MS"|"CPU_BATCH_BASE"|"CPU_BATCH_MIN"|"CPU_BATCH_MAX"|"CPU_BATCH_SIZE"|"GPU_BATCH_BASE"|"GPU_BATCH_MIN"|"GPU_BATCH_MAX"|"OPENCL_BATCH_SIZE"|"OPENCL_LOCAL_WORK_SIZE"|"AUTOLYKOS_BLOCK_SIZE"|"OPENCL_AUTOTUNE"|"CUDA_BATCH_SIZE"|"CUDA_BLOCK_SIZE"|"CUDA_AUTOTUNE"|"CPU_AUTOTUNE"|"CPU_AUTOTUNE_PROBE_MS"|"GPU_AUTOTUNE_ROUNDS"|"HIVE_STATS_PATH"|"HIVE_STATS_DISABLED"|"HIVE_PATH"|"HIVE_DISABLED")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

safe_csv="${CUSTOM_URL:-}"
pool_url="$(kv_from_csv "${safe_csv}" "POOL" || true)"
template_from_url="$(kv_from_csv "${safe_csv}" "TEMPLATE" || true)"
pass_from_url="$(kv_from_csv "${safe_csv}" "PASS" || true)"
proto_from_url="$(kv_from_csv "${safe_csv}" "PROTO" || true)"
proto_fallback_from_url="$(kv_from_csv "${safe_csv}" "PROTO_FALLBACK" || true)"
stratum_protocol_fallback_from_url="$(kv_from_csv "${safe_csv}" "STRATUM_PROTOCOL_FALLBACK" || true)"
transport_from_url="$(kv_from_csv "${safe_csv}" "TRANSPORT" || true)"
algo_from_url="$(kv_from_csv "${safe_csv}" "ALGO" || true)"
coin_from_url="$(kv_from_csv "${safe_csv}" "COIN" || true)"
hash_from_url="$(kv_from_csv "${safe_csv}" "HASH" || true)"
randomx_hugepages_from_url="$(kv_from_csv "${safe_csv}" "RANDOMX_HUGEPAGES" || true)"
randomx_msr_from_url="$(kv_from_csv "${safe_csv}" "RANDOMX_MSR" || true)"
cpu_coin_from_url="$(kv_from_csv "${safe_csv}" "CPU_COIN" || true)"
cpu_hash_from_url="$(kv_from_csv "${safe_csv}" "CPU_HASH" || true)"
gpu_coin_from_url="$(kv_from_csv "${safe_csv}" "GPU_COIN" || true)"
gpu_hash_from_url="$(kv_from_csv "${safe_csv}" "GPU_HASH" || true)"
cpu_pool_from_url="$(kv_from_csv "${safe_csv}" "CPU_POOL" || true)"
cpu_failover_pools_from_url="$(kv_from_csv "${safe_csv}" "CPU_FAILOVER_POOLS" || true)"
cpu_proto_from_url="$(kv_from_csv "${safe_csv}" "CPU_PROTO" || true)"
cpu_stratum_protocol_from_url="$(kv_from_csv "${safe_csv}" "CPU_STRATUM_PROTOCOL" || true)"
cpu_user_from_url="$(kv_from_csv "${safe_csv}" "CPU_USER" || true)"
cpu_password_from_url="$(kv_from_csv "${safe_csv}" "CPU_PASSWORD" || true)"
cpu_wallet_from_url="$(kv_from_csv "${safe_csv}" "CPU_WALLET" || true)"
gpu_pool_from_url="$(kv_from_csv "${safe_csv}" "GPU_POOL" || true)"
gpu_failover_pools_from_url="$(kv_from_csv "${safe_csv}" "GPU_FAILOVER_POOLS" || true)"
gpu_proto_from_url="$(kv_from_csv "${safe_csv}" "GPU_PROTO" || true)"
gpu_stratum_protocol_from_url="$(kv_from_csv "${safe_csv}" "GPU_STRATUM_PROTOCOL" || true)"
gpu_user_from_url="$(kv_from_csv "${safe_csv}" "GPU_USER" || true)"
gpu_password_from_url="$(kv_from_csv "${safe_csv}" "GPU_PASSWORD" || true)"
gpu_wallet_from_url="$(kv_from_csv "${safe_csv}" "GPU_WALLET" || true)"
worker_from_url="$(kv_from_csv "${safe_csv}" "WORKER" || true)"
api_bind_from_url="$(kv_from_csv "${safe_csv}" "API_BIND" || true)"
api_port_from_url="$(kv_from_csv "${safe_csv}" "API_PORT" || true)"
api_token_from_url="$(kv_from_csv "${safe_csv}" "API_TOKEN" || true)"
frontend_bind_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_BIND" || true)"
frontend_port_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_PORT" || true)"
frontend_disabled_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_DISABLED" || true)"
frontend_logs_disabled_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_LOGS_DISABLED" || true)"
frontend_password_enabled_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_PASSWORD_ENABLED" || true)"
frontend_password_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_PASSWORD" || true)"
frontend_rate_limit_per_minute_from_url="$(kv_from_csv "${safe_csv}" "FRONTEND_RATE_LIMIT_PER_MINUTE" || true)"
bench_report_from_url="$(kv_from_csv "${safe_csv}" "BENCH_REPORT" || true)"
bench_report_interval_sec_from_url="$(kv_from_csv "${safe_csv}" "BENCH_REPORT_INTERVAL_SEC" || true)"
bench_report_id_file_from_url="$(kv_from_csv "${safe_csv}" "BENCH_REPORT_ID_FILE" || true)"
bench_report_api_key_from_url="$(kv_from_csv "${safe_csv}" "BENCH_REPORT_API_KEY" || true)"
bench_insights_from_url="$(kv_from_csv "${safe_csv}" "BENCH_INSIGHTS" || true)"
no_cpu_from_url="$(kv_from_csv "${safe_csv}" "NO_CPU" || true)"
no_gpu_from_url="$(kv_from_csv "${safe_csv}" "NO_GPU" || true)"
gpu_devices_from_url="$(kv_from_csv "${safe_csv}" "GPU_DEVICES" || true)"
cuda_devices_from_url="$(kv_from_csv "${safe_csv}" "CUDA_DEVICES" || true)"
opencl_devices_from_url="$(kv_from_csv "${safe_csv}" "OPENCL_DEVICES" || true)"
gpu_backend_from_url="$(kv_from_csv "${safe_csv}" "GPU_BACKEND" || true)"
intensity_from_url="$(kv_from_csv "${safe_csv}" "INTENSITY" || true)"
intensity_min_from_url="$(kv_from_csv "${safe_csv}" "INTENSITY_MIN" || true)"
intensity_max_from_url="$(kv_from_csv "${safe_csv}" "INTENSITY_MAX" || true)"
cpu_intensity_from_url="$(kv_from_csv "${safe_csv}" "CPU_INTENSITY" || true)"
gpu_intensity_from_url="$(kv_from_csv "${safe_csv}" "GPU_INTENSITY" || true)"
no_cuda_from_url="$(kv_from_csv "${safe_csv}" "NO_CUDA" || true)"
no_opencl_from_url="$(kv_from_csv "${safe_csv}" "NO_OPENCL" || true)"
disable_gpu_amd_from_url="$(kv_from_csv "${safe_csv}" "DISABLE_GPU_AMD" || true)"
disable_gpu_nvidia_from_url="$(kv_from_csv "${safe_csv}" "DISABLE_GPU_NVIDIA" || true)"
disable_gpu_intel_from_url="$(kv_from_csv "${safe_csv}" "DISABLE_GPU_INTEL" || true)"
pool_retry_count_from_url="$(kv_from_csv "${safe_csv}" "RETRY_COUNT" || true)"
pool_retry_delay_ms_from_url="$(kv_from_csv "${safe_csv}" "RETRY_DELAY_MS" || true)"
pool_connect_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "CONNECT_TIMEOUT_MS" || true)"
pool_tls_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "TLS_TIMEOUT_MS" || true)"
pool_request_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "REQUEST_TIMEOUT_MS" || true)"
pool_job_channel_size_from_url="$(kv_from_csv "${safe_csv}" "JOB_CHANNEL_SIZE" || true)"
job_recv_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "JOB_RECV_TIMEOUT_MS" || true)"
stats_interval_ms_from_url="$(kv_from_csv "${safe_csv}" "STATS_INTERVAL_MS" || true)"
share_queue_capacity_from_url="$(kv_from_csv "${safe_csv}" "SHARE_QUEUE_CAPACITY" || true)"
share_submit_rate_from_url="$(kv_from_csv "${safe_csv}" "SHARE_SUBMIT_RATE" || true)"
share_submit_burst_from_url="$(kv_from_csv "${safe_csv}" "SHARE_SUBMIT_BURST" || true)"
recent_job_max_ids_from_url="$(kv_from_csv "${safe_csv}" "RECENT_JOB_MAX_IDS" || true)"
recent_job_max_age_ms_from_url="$(kv_from_csv "${safe_csv}" "RECENT_JOB_MAX_AGE_MS" || true)"
gpu_status_board_interval_ms_from_url="$(kv_from_csv "${safe_csv}" "GPU_STATUS_BOARD_INTERVAL_MS" || true)"
hybrid_cpu_reserve_min_cores_from_url="$(kv_from_csv "${safe_csv}" "HYBRID_CPU_RESERVE_MIN_CORES" || true)"
hybrid_cpu_reserve_max_cores_from_url="$(kv_from_csv "${safe_csv}" "HYBRID_CPU_RESERVE_MAX_CORES" || true)"
hybrid_cpu_reserve_gpu_threshold_from_url="$(kv_from_csv "${safe_csv}" "HYBRID_CPU_RESERVE_GPU_THRESHOLD" || true)"
task_drain_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "TASK_DRAIN_TIMEOUT_MS" || true)"
shutdown_poll_ms_from_url="$(kv_from_csv "${safe_csv}" "SHUTDOWN_POLL_MS" || true)"
reconnect_min_delay_ms_from_url="$(kv_from_csv "${safe_csv}" "RECONNECT_MIN_DELAY_MS" || true)"
reconnect_backoff_max_power_from_url="$(kv_from_csv "${safe_csv}" "RECONNECT_BACKOFF_MAX_POWER" || true)"
worker_idle_sleep_ms_from_url="$(kv_from_csv "${safe_csv}" "WORKER_IDLE_SLEEP_MS" || true)"
worker_recv_timeout_ms_from_url="$(kv_from_csv "${safe_csv}" "WORKER_RECV_TIMEOUT_MS" || true)"
worker_max_slice_ms_from_url="$(kv_from_csv "${safe_csv}" "WORKER_MAX_SLICE_MS" || true)"
worker_slice_check_interval_from_url="$(kv_from_csv "${safe_csv}" "WORKER_SLICE_CHECK_INTERVAL" || true)"
worker_active_poll_interval_from_url="$(kv_from_csv "${safe_csv}" "WORKER_ACTIVE_POLL_INTERVAL" || true)"
worker_stats_flush_threshold_from_url="$(kv_from_csv "${safe_csv}" "WORKER_STATS_FLUSH_THRESHOLD" || true)"
worker_stats_flush_interval_ms_from_url="$(kv_from_csv "${safe_csv}" "WORKER_STATS_FLUSH_INTERVAL_MS" || true)"
cpu_batch_base_from_url="$(kv_from_csv "${safe_csv}" "CPU_BATCH_BASE" || true)"
cpu_batch_min_from_url="$(kv_from_csv "${safe_csv}" "CPU_BATCH_MIN" || true)"
cpu_batch_max_from_url="$(kv_from_csv "${safe_csv}" "CPU_BATCH_MAX" || true)"
cpu_batch_size_from_url="$(kv_from_csv "${safe_csv}" "CPU_BATCH_SIZE" || true)"
gpu_batch_base_from_url="$(kv_from_csv "${safe_csv}" "GPU_BATCH_BASE" || true)"
gpu_batch_min_from_url="$(kv_from_csv "${safe_csv}" "GPU_BATCH_MIN" || true)"
gpu_batch_max_from_url="$(kv_from_csv "${safe_csv}" "GPU_BATCH_MAX" || true)"
opencl_batch_size_from_url="$(kv_from_csv "${safe_csv}" "OPENCL_BATCH_SIZE" || true)"
opencl_local_work_size_from_url="$(kv_from_csv "${safe_csv}" "OPENCL_LOCAL_WORK_SIZE" || true)"
autolykos_block_size_from_url="$(kv_from_csv "${safe_csv}" "AUTOLYKOS_BLOCK_SIZE" || true)"
opencl_autotune_from_url="$(kv_from_csv "${safe_csv}" "OPENCL_AUTOTUNE" || true)"
cuda_batch_size_from_url="$(kv_from_csv "${safe_csv}" "CUDA_BATCH_SIZE" || true)"
cuda_block_size_from_url="$(kv_from_csv "${safe_csv}" "CUDA_BLOCK_SIZE" || true)"
cuda_autotune_from_url="$(kv_from_csv "${safe_csv}" "CUDA_AUTOTUNE" || true)"
cpu_autotune_from_url="$(kv_from_csv "${safe_csv}" "CPU_AUTOTUNE" || true)"
cpu_autotune_probe_ms_from_url="$(kv_from_csv "${safe_csv}" "CPU_AUTOTUNE_PROBE_MS" || true)"
gpu_autotune_rounds_from_url="$(kv_from_csv "${safe_csv}" "GPU_AUTOTUNE_ROUNDS" || true)"
hive_stats_path_from_url="$(kv_from_csv "${safe_csv}" "HIVE_STATS_PATH" || true)"
hive_stats_disabled_from_url="$(kv_from_csv "${safe_csv}" "HIVE_STATS_DISABLED" || true)"
hive_path_from_url="$(kv_from_csv "${safe_csv}" "HIVE_PATH" || true)"
hive_disabled_from_url="$(kv_from_csv "${safe_csv}" "HIVE_DISABLED" || true)"

if [[ -z "${hive_stats_path_from_url}" ]]; then
  hive_stats_path_from_url="${hive_path_from_url}"
fi

if [[ -z "${hive_stats_disabled_from_url}" ]]; then
  hive_stats_disabled_from_url="${hive_disabled_from_url}"
fi

if [[ -z "${pool_url}" ]]; then
  pool_url="$(trim "${safe_csv}")"
fi

if [[ -z "${pool_url}" ]]; then
  echo "CUSTOM_URL/POOL is empty; cannot build miner config" >&2
  exit 1
fi

pool_user="${CUSTOM_TEMPLATE:-${template_from_url:-}}"
worker_name="${worker_from_url:-${WORKER_NAME:-worker}}"

if [[ -z "${pool_user}" ]]; then
  pool_user="${worker_name}"
fi

pool_pass="${CUSTOM_PASS:-${pass_from_url:-x}}"
stratum_protocol="${CUSTOM_STRATUM_PROTOCOL:-${proto_from_url:-v1}}"
stratum_protocol_fallback="${CUSTOM_STRATUM_PROTOCOL_FALLBACK:-${stratum_protocol_fallback_from_url:-${proto_fallback_from_url:-}}}"
stratum_transport="${CUSTOM_STRATUM_TRANSPORT:-${transport_from_url:-auto}}"
algorithm="${CUSTOM_ALGO:-${algo_from_url:-}}"
coin="${CUSTOM_COIN:-${coin_from_url:-}}"
hash_name="${CUSTOM_HASH:-${hash_from_url:-}}"
randomx_hugepages="${CUSTOM_RANDOMX_HUGEPAGES:-${randomx_hugepages_from_url:-}}"
randomx_msr="${CUSTOM_RANDOMX_MSR:-${randomx_msr_from_url:-}}"
cpu_coin="${CUSTOM_CPU_COIN:-${cpu_coin_from_url:-}}"
cpu_hash="${CUSTOM_CPU_HASH:-${cpu_hash_from_url:-}}"
gpu_coin="${CUSTOM_GPU_COIN:-${gpu_coin_from_url:-}}"
gpu_hash="${CUSTOM_GPU_HASH:-${gpu_hash_from_url:-}}"
cpu_pool="${CUSTOM_CPU_POOL:-${cpu_pool_from_url:-}}"
cpu_failover_pools="${CUSTOM_CPU_FAILOVER_POOLS:-${cpu_failover_pools_from_url:-}}"
cpu_stratum_protocol="${CUSTOM_CPU_STRATUM_PROTOCOL:-${cpu_stratum_protocol_from_url:-${cpu_proto_from_url:-}}}"
cpu_user="${CUSTOM_CPU_USER:-${cpu_user_from_url:-}}"
cpu_password="${CUSTOM_CPU_PASSWORD:-${cpu_password_from_url:-}}"
cpu_wallet="${CUSTOM_CPU_WALLET:-${cpu_wallet_from_url:-}}"
gpu_pool="${CUSTOM_GPU_POOL:-${gpu_pool_from_url:-}}"
gpu_failover_pools="${CUSTOM_GPU_FAILOVER_POOLS:-${gpu_failover_pools_from_url:-}}"
gpu_stratum_protocol="${CUSTOM_GPU_STRATUM_PROTOCOL:-${gpu_stratum_protocol_from_url:-${gpu_proto_from_url:-}}}"
gpu_user="${CUSTOM_GPU_USER:-${gpu_user_from_url:-}}"
gpu_password="${CUSTOM_GPU_PASSWORD:-${gpu_password_from_url:-}}"
gpu_wallet="${CUSTOM_GPU_WALLET:-${gpu_wallet_from_url:-}}"
extra_args="${CUSTOM_USER_CONFIG:-}"
api_bind="${CUSTOM_API_BIND:-${api_bind_from_url:-127.0.0.1}}"
api_port="${CUSTOM_API_PORT:-${api_port_from_url:-48673}}"
api_token="${CUSTOM_API_TOKEN:-${api_token_from_url:-}}"
frontend_bind="${CUSTOM_FRONTEND_BIND:-${frontend_bind_from_url:-127.0.0.1}}"
frontend_port="${CUSTOM_FRONTEND_PORT:-${frontend_port_from_url:-8943}}"
frontend_disabled="${CUSTOM_FRONTEND_DISABLED:-${frontend_disabled_from_url:-0}}"
frontend_logs_disabled="${CUSTOM_FRONTEND_LOGS_DISABLED:-${frontend_logs_disabled_from_url:-0}}"
frontend_password_enabled="${CUSTOM_FRONTEND_PASSWORD_ENABLED:-${frontend_password_enabled_from_url:-0}}"
frontend_password="${CUSTOM_FRONTEND_PASSWORD:-${frontend_password_from_url:-}}"
frontend_rate_limit_per_minute="${CUSTOM_FRONTEND_RATE_LIMIT_PER_MINUTE:-${frontend_rate_limit_per_minute_from_url:-}}"
bench_report="${CUSTOM_BENCH_REPORT:-${bench_report_from_url:-1}}"
bench_report_interval_sec="${CUSTOM_BENCH_REPORT_INTERVAL_SEC:-${bench_report_interval_sec_from_url:-}}"
bench_report_id_file="${CUSTOM_BENCH_REPORT_ID_FILE:-${bench_report_id_file_from_url:-}}"
bench_report_api_key="${CUSTOM_BENCH_REPORT_API_KEY:-${bench_report_api_key_from_url:-}}"
bench_insights="${CUSTOM_BENCH_INSIGHTS:-${bench_insights_from_url:-1}}"
no_cpu="${CUSTOM_NO_CPU:-${no_cpu_from_url:-0}}"
no_gpu="${CUSTOM_NO_GPU:-${no_gpu_from_url:-0}}"
gpu_devices="${CUSTOM_GPU_DEVICES:-${gpu_devices_from_url:-}}"
cuda_devices="${CUSTOM_CUDA_DEVICES:-${cuda_devices_from_url:-}}"
opencl_devices="${CUSTOM_OPENCL_DEVICES:-${opencl_devices_from_url:-}}"
gpu_backend="${CUSTOM_GPU_BACKEND:-${gpu_backend_from_url:-auto}}"
intensity="${CUSTOM_INTENSITY:-${intensity_from_url:-}}"
intensity_min="${CUSTOM_INTENSITY_MIN:-${intensity_min_from_url:-}}"
intensity_max="${CUSTOM_INTENSITY_MAX:-${intensity_max_from_url:-}}"
cpu_intensity="${CUSTOM_CPU_INTENSITY:-${cpu_intensity_from_url:-}}"
gpu_intensity="${CUSTOM_GPU_INTENSITY:-${gpu_intensity_from_url:-}}"
no_cuda="${CUSTOM_NO_CUDA:-${no_cuda_from_url:-0}}"
no_opencl="${CUSTOM_NO_OPENCL:-${no_opencl_from_url:-0}}"
disable_gpu_amd="${CUSTOM_DISABLE_GPU_AMD:-${disable_gpu_amd_from_url:-0}}"
disable_gpu_nvidia="${CUSTOM_DISABLE_GPU_NVIDIA:-${disable_gpu_nvidia_from_url:-0}}"
disable_gpu_intel="${CUSTOM_DISABLE_GPU_INTEL:-${disable_gpu_intel_from_url:-0}}"
pool_retry_count="${CUSTOM_POOL_RETRY_COUNT:-${pool_retry_count_from_url:-}}"
pool_retry_delay_ms="${CUSTOM_POOL_RETRY_DELAY_MS:-${pool_retry_delay_ms_from_url:-}}"
pool_connect_timeout_ms="${CUSTOM_POOL_CONNECT_TIMEOUT_MS:-${pool_connect_timeout_ms_from_url:-}}"
pool_tls_timeout_ms="${CUSTOM_POOL_TLS_TIMEOUT_MS:-${pool_tls_timeout_ms_from_url:-}}"
pool_request_timeout_ms="${CUSTOM_POOL_REQUEST_TIMEOUT_MS:-${pool_request_timeout_ms_from_url:-}}"
pool_job_channel_size="${CUSTOM_POOL_JOB_CHANNEL_SIZE:-${pool_job_channel_size_from_url:-}}"
job_recv_timeout_ms="${CUSTOM_JOB_RECV_TIMEOUT_MS:-${job_recv_timeout_ms_from_url:-}}"
stats_interval_ms="${CUSTOM_STATS_INTERVAL_MS:-${stats_interval_ms_from_url:-}}"
share_queue_capacity="${CUSTOM_SHARE_QUEUE_CAPACITY:-${share_queue_capacity_from_url:-}}"
share_submit_rate="${CUSTOM_SHARE_SUBMIT_RATE:-${share_submit_rate_from_url:-}}"
share_submit_burst="${CUSTOM_SHARE_SUBMIT_BURST:-${share_submit_burst_from_url:-}}"
recent_job_max_ids="${CUSTOM_RECENT_JOB_MAX_IDS:-${recent_job_max_ids_from_url:-}}"
recent_job_max_age_ms="${CUSTOM_RECENT_JOB_MAX_AGE_MS:-${recent_job_max_age_ms_from_url:-}}"
gpu_status_board_interval_ms="${CUSTOM_GPU_STATUS_BOARD_INTERVAL_MS:-${gpu_status_board_interval_ms_from_url:-}}"
hybrid_cpu_reserve_min_cores="${CUSTOM_HYBRID_CPU_RESERVE_MIN_CORES:-${hybrid_cpu_reserve_min_cores_from_url:-}}"
hybrid_cpu_reserve_max_cores="${CUSTOM_HYBRID_CPU_RESERVE_MAX_CORES:-${hybrid_cpu_reserve_max_cores_from_url:-}}"
hybrid_cpu_reserve_gpu_threshold="${CUSTOM_HYBRID_CPU_RESERVE_GPU_THRESHOLD:-${hybrid_cpu_reserve_gpu_threshold_from_url:-}}"
task_drain_timeout_ms="${CUSTOM_TASK_DRAIN_TIMEOUT_MS:-${task_drain_timeout_ms_from_url:-}}"
shutdown_poll_ms="${CUSTOM_SHUTDOWN_POLL_MS:-${shutdown_poll_ms_from_url:-}}"
reconnect_min_delay_ms="${CUSTOM_RECONNECT_MIN_DELAY_MS:-${reconnect_min_delay_ms_from_url:-}}"
reconnect_backoff_max_power="${CUSTOM_RECONNECT_BACKOFF_MAX_POWER:-${reconnect_backoff_max_power_from_url:-}}"
worker_idle_sleep_ms="${CUSTOM_WORKER_IDLE_SLEEP_MS:-${worker_idle_sleep_ms_from_url:-}}"
worker_recv_timeout_ms="${CUSTOM_WORKER_RECV_TIMEOUT_MS:-${worker_recv_timeout_ms_from_url:-}}"
worker_max_slice_ms="${CUSTOM_WORKER_MAX_SLICE_MS:-${worker_max_slice_ms_from_url:-}}"
worker_slice_check_interval="${CUSTOM_WORKER_SLICE_CHECK_INTERVAL:-${worker_slice_check_interval_from_url:-}}"
worker_active_poll_interval="${CUSTOM_WORKER_ACTIVE_POLL_INTERVAL:-${worker_active_poll_interval_from_url:-}}"
worker_stats_flush_threshold="${CUSTOM_WORKER_STATS_FLUSH_THRESHOLD:-${worker_stats_flush_threshold_from_url:-}}"
worker_stats_flush_interval_ms="${CUSTOM_WORKER_STATS_FLUSH_INTERVAL_MS:-${worker_stats_flush_interval_ms_from_url:-}}"
cpu_batch_base="${CUSTOM_CPU_BATCH_BASE:-${cpu_batch_base_from_url:-}}"
cpu_batch_min="${CUSTOM_CPU_BATCH_MIN:-${cpu_batch_min_from_url:-}}"
cpu_batch_max="${CUSTOM_CPU_BATCH_MAX:-${cpu_batch_max_from_url:-}}"
cpu_batch_size="${CUSTOM_CPU_BATCH_SIZE:-${cpu_batch_size_from_url:-}}"
gpu_batch_base="${CUSTOM_GPU_BATCH_BASE:-${gpu_batch_base_from_url:-}}"
gpu_batch_min="${CUSTOM_GPU_BATCH_MIN:-${gpu_batch_min_from_url:-}}"
gpu_batch_max="${CUSTOM_GPU_BATCH_MAX:-${gpu_batch_max_from_url:-}}"
opencl_batch_size="${CUSTOM_OPENCL_BATCH_SIZE:-${opencl_batch_size_from_url:-}}"
opencl_local_work_size="${CUSTOM_OPENCL_LOCAL_WORK_SIZE:-${opencl_local_work_size_from_url:-}}"
autolykos_block_size="${CUSTOM_AUTOLYKOS_BLOCK_SIZE:-${autolykos_block_size_from_url:-}}"
opencl_autotune="${CUSTOM_OPENCL_AUTOTUNE:-${opencl_autotune_from_url:-}}"
cuda_batch_size="${CUSTOM_CUDA_BATCH_SIZE:-${cuda_batch_size_from_url:-}}"
cuda_block_size="${CUSTOM_CUDA_BLOCK_SIZE:-${cuda_block_size_from_url:-}}"
cuda_autotune="${CUSTOM_CUDA_AUTOTUNE:-${cuda_autotune_from_url:-}}"
cpu_autotune="${CUSTOM_CPU_AUTOTUNE:-${cpu_autotune_from_url:-}}"
cpu_autotune_probe_ms="${CUSTOM_CPU_AUTOTUNE_PROBE_MS:-${cpu_autotune_probe_ms_from_url:-}}"
gpu_autotune_rounds="${CUSTOM_GPU_AUTOTUNE_ROUNDS:-${gpu_autotune_rounds_from_url:-}}"
hive_stats_path="${CUSTOM_HIVE_STATS_PATH:-${hive_stats_path_from_url:-/hiveos/stats}}"
hive_stats_disabled="${CUSTOM_HIVE_STATS_DISABLED:-${hive_stats_disabled_from_url:-0}}"

normalize_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

canonical_coin() {
  case "$(normalize_lower "$(trim "$1")")" in
    "cryptix")
      printf 'cryptix'
      ;;
    "monero"|"xmr")
      printf 'monero'
      ;;
    "zephyr"|"zeph")
      printf 'zephyr'
      ;;
    "ergo"|"erg")
      printf 'ergo'
      ;;
    "unknown"|"unkown")
      printf 'unknown'
      ;;
    *)
      return 1
      ;;
  esac
}

canonical_hash() {
  case "$(normalize_lower "$(trim "$1")")" in
    "ox8"|"cryptix-ox8"|"cryptixox8")
      printf 'ox8'
      ;;
    "randomx"|"random-x"|"rx"|"rx/0"|"rx-0")
      printf 'randomx'
      ;;
    "autolykosv2"|"autolykos-v2"|"autolykos2"|"autolykos")
      printf 'autolykosv2'
      ;;
    *)
      return 1
      ;;
  esac
}

normalize_pool_list() {
  local raw="$1"
  raw="$(trim "${raw}")"
  raw="${raw//|/,}"
  raw="${raw//;/,}"
  raw="$(printf '%s' "${raw}" | sed -E 's/[[:space:]]*,[[:space:]]*/,/g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  printf '%s' "${raw}"
}

normalize_optional_coin() {
  local raw
  raw="$(trim "${1:-}")"
  if [[ -z "${raw}" ]]; then
    printf ''
    return 0
  fi
  canonical_coin "${raw}"
}

normalize_optional_hash() {
  local raw
  raw="$(trim "${1:-}")"
  if [[ -z "${raw}" ]]; then
    printf ''
    return 0
  fi
  canonical_hash "${raw}"
}

if [[ -z "${coin}" || -z "${hash_name}" ]]; then
  case "$(normalize_lower "${algorithm}")" in
    ""|"cryptix-ox8"|"cryptixox8"|"ox8")
      coin="${coin:-cryptix}"
      hash_name="${hash_name:-ox8}"
      ;;
    "randomx"|"random-x"|"rx"|"rx/0"|"rx-0")
      coin="${coin:-monero}"
      hash_name="${hash_name:-randomx}"
      ;;
    "autolykosv2"|"autolykos-v2"|"autolykos2"|"autolykos")
      coin="${coin:-ergo}"
      hash_name="${hash_name:-autolykosv2}"
      ;;
    *)
      echo "Unsupported ALGO '${algorithm}'. Use COIN/HASH with: cryptix+ox8, monero+randomx, zephyr+randomx, ergo+autolykosv2, unknown+ox8, unknown+randomx, unknown+autolykosv2." >&2
      exit 1
      ;;
  esac
fi

if ! coin="$(canonical_coin "${coin}")"; then
  echo "Unsupported COIN '${coin}'. Supported: cryptix, monero, zephyr, ergo, unknown." >&2
  exit 1
fi
if ! hash_name="$(canonical_hash "${hash_name}")"; then
  echo "Unsupported HASH '${hash_name}'. Supported: ox8, randomx, autolykosv2." >&2
  exit 1
fi

case "${coin}" in
  "cryptix")
    if [[ "${hash_name}" != "ox8" ]]; then
      echo "Unsupported pair '${coin}+${hash_name}'. cryptix supports only ox8." >&2
      exit 1
    fi
    algorithm="cryptix-ox8"
    ;;
  "monero"|"zephyr")
    if [[ "${hash_name}" != "randomx" ]]; then
      echo "Unsupported pair '${coin}+${hash_name}'. ${coin} supports only randomx." >&2
      exit 1
    fi
    algorithm="randomx"
    ;;
  "ergo")
    if [[ "${hash_name}" != "autolykosv2" ]]; then
      echo "Unsupported pair '${coin}+${hash_name}'. ${coin} supports only autolykosv2." >&2
      exit 1
    fi
    algorithm="autolykosv2"
    ;;
  "unknown")
    if [[ "${hash_name}" == "ox8" ]]; then
      algorithm="cryptix-ox8"
    elif [[ "${hash_name}" == "randomx" ]]; then
      algorithm="randomx"
    else
      algorithm="autolykosv2"
    fi
    ;;
esac

if ! cpu_coin="$(normalize_optional_coin "${cpu_coin}")"; then
  echo "Unsupported CPU_COIN '${cpu_coin}'." >&2
  exit 1
fi
if ! cpu_hash="$(normalize_optional_hash "${cpu_hash}")"; then
  echo "Unsupported CPU_HASH '${cpu_hash}'." >&2
  exit 1
fi
if ! gpu_coin="$(normalize_optional_coin "${gpu_coin}")"; then
  echo "Unsupported GPU_COIN '${gpu_coin}'." >&2
  exit 1
fi
if ! gpu_hash="$(normalize_optional_hash "${gpu_hash}")"; then
  echo "Unsupported GPU_HASH '${gpu_hash}'." >&2
  exit 1
fi

cpu_failover_pools="$(normalize_pool_list "${cpu_failover_pools}")"
gpu_failover_pools="$(normalize_pool_list "${gpu_failover_pools}")"

mkdir -p "$(dirname "${CUSTOM_CONFIG_FILENAME}")"

{
  printf 'POOL_URL=%q\n' "${pool_url}"
  printf 'POOL_USER=%q\n' "${pool_user}"
  printf 'POOL_PASS=%q\n' "${pool_pass}"
  printf 'WORKER_NAME_VALUE=%q\n' "${worker_name}"
  printf 'COIN=%q\n' "${coin}"
  printf 'HASH_NAME=%q\n' "${hash_name}"
  printf 'RANDOMX_HUGEPAGES=%q\n' "${randomx_hugepages}"
  printf 'RANDOMX_MSR=%q\n' "${randomx_msr}"
  printf 'ALGORITHM=%q\n' "${algorithm}"
  printf 'CPU_COIN=%q\n' "${cpu_coin}"
  printf 'CPU_HASH=%q\n' "${cpu_hash}"
  printf 'GPU_COIN=%q\n' "${gpu_coin}"
  printf 'GPU_HASH=%q\n' "${gpu_hash}"
  printf 'CPU_POOL=%q\n' "${cpu_pool}"
  printf 'CPU_FAILOVER_POOLS=%q\n' "${cpu_failover_pools}"
  printf 'CPU_STRATUM_PROTOCOL=%q\n' "${cpu_stratum_protocol}"
  printf 'CPU_USER=%q\n' "${cpu_user}"
  printf 'CPU_PASSWORD=%q\n' "${cpu_password}"
  printf 'CPU_WALLET=%q\n' "${cpu_wallet}"
  printf 'GPU_POOL=%q\n' "${gpu_pool}"
  printf 'GPU_FAILOVER_POOLS=%q\n' "${gpu_failover_pools}"
  printf 'GPU_STRATUM_PROTOCOL=%q\n' "${gpu_stratum_protocol}"
  printf 'GPU_USER=%q\n' "${gpu_user}"
  printf 'GPU_PASSWORD=%q\n' "${gpu_password}"
  printf 'GPU_WALLET=%q\n' "${gpu_wallet}"
  printf 'STRATUM_PROTOCOL=%q\n' "${stratum_protocol}"
  printf 'STRATUM_PROTOCOL_FALLBACK=%q\n' "${stratum_protocol_fallback}"
  printf 'STRATUM_TRANSPORT=%q\n' "${stratum_transport}"
  printf 'EXTRA_ARGS=%q\n' "${extra_args}"
  printf 'API_BIND=%q\n' "${api_bind}"
  printf 'API_PORT=%q\n' "${api_port}"
  printf 'API_TOKEN=%q\n' "${api_token}"
  printf 'FRONTEND_BIND=%q\n' "${frontend_bind}"
  printf 'FRONTEND_PORT=%q\n' "${frontend_port}"
  printf 'FRONTEND_DISABLED=%q\n' "${frontend_disabled}"
  printf 'FRONTEND_LOGS_DISABLED=%q\n' "${frontend_logs_disabled}"
  printf 'FRONTEND_PASSWORD_ENABLED=%q\n' "${frontend_password_enabled}"
  printf 'FRONTEND_PASSWORD=%q\n' "${frontend_password}"
  printf 'FRONTEND_RATE_LIMIT_PER_MINUTE=%q\n' "${frontend_rate_limit_per_minute}"
  printf 'BENCH_REPORT=%q\n' "${bench_report}"
  printf 'BENCH_REPORT_INTERVAL_SEC=%q\n' "${bench_report_interval_sec}"
  printf 'BENCH_REPORT_ID_FILE=%q\n' "${bench_report_id_file}"
  printf 'BENCH_REPORT_API_KEY=%q\n' "${bench_report_api_key}"
  printf 'BENCH_INSIGHTS=%q\n' "${bench_insights}"
  printf 'NO_CPU=%q\n' "${no_cpu}"
  printf 'NO_GPU=%q\n' "${no_gpu}"
  printf 'GPU_DEVICES=%q\n' "${gpu_devices}"
  printf 'CUDA_DEVICES=%q\n' "${cuda_devices}"
  printf 'OPENCL_DEVICES=%q\n' "${opencl_devices}"
  printf 'GPU_BACKEND=%q\n' "${gpu_backend}"
  printf 'INTENSITY=%q\n' "${intensity}"
  printf 'INTENSITY_MIN=%q\n' "${intensity_min}"
  printf 'INTENSITY_MAX=%q\n' "${intensity_max}"
  printf 'CPU_INTENSITY=%q\n' "${cpu_intensity}"
  printf 'GPU_INTENSITY=%q\n' "${gpu_intensity}"
  printf 'NO_CUDA=%q\n' "${no_cuda}"
  printf 'NO_OPENCL=%q\n' "${no_opencl}"
  printf 'DISABLE_GPU_AMD=%q\n' "${disable_gpu_amd}"
  printf 'DISABLE_GPU_NVIDIA=%q\n' "${disable_gpu_nvidia}"
  printf 'DISABLE_GPU_INTEL=%q\n' "${disable_gpu_intel}"
  printf 'POOL_RETRY_COUNT=%q\n' "${pool_retry_count}"
  printf 'POOL_RETRY_DELAY_MS=%q\n' "${pool_retry_delay_ms}"
  printf 'POOL_CONNECT_TIMEOUT_MS=%q\n' "${pool_connect_timeout_ms}"
  printf 'POOL_TLS_TIMEOUT_MS=%q\n' "${pool_tls_timeout_ms}"
  printf 'POOL_REQUEST_TIMEOUT_MS=%q\n' "${pool_request_timeout_ms}"
  printf 'POOL_JOB_CHANNEL_SIZE=%q\n' "${pool_job_channel_size}"
  printf 'JOB_RECV_TIMEOUT_MS=%q\n' "${job_recv_timeout_ms}"
  printf 'STATS_INTERVAL_MS=%q\n' "${stats_interval_ms}"
  printf 'SHARE_QUEUE_CAPACITY=%q\n' "${share_queue_capacity}"
  printf 'SHARE_SUBMIT_RATE=%q\n' "${share_submit_rate}"
  printf 'SHARE_SUBMIT_BURST=%q\n' "${share_submit_burst}"
  printf 'RECENT_JOB_MAX_IDS=%q\n' "${recent_job_max_ids}"
  printf 'RECENT_JOB_MAX_AGE_MS=%q\n' "${recent_job_max_age_ms}"
  printf 'GPU_STATUS_BOARD_INTERVAL_MS=%q\n' "${gpu_status_board_interval_ms}"
  printf 'HYBRID_CPU_RESERVE_MIN_CORES=%q\n' "${hybrid_cpu_reserve_min_cores}"
  printf 'HYBRID_CPU_RESERVE_MAX_CORES=%q\n' "${hybrid_cpu_reserve_max_cores}"
  printf 'HYBRID_CPU_RESERVE_GPU_THRESHOLD=%q\n' "${hybrid_cpu_reserve_gpu_threshold}"
  printf 'TASK_DRAIN_TIMEOUT_MS=%q\n' "${task_drain_timeout_ms}"
  printf 'SHUTDOWN_POLL_MS=%q\n' "${shutdown_poll_ms}"
  printf 'RECONNECT_MIN_DELAY_MS=%q\n' "${reconnect_min_delay_ms}"
  printf 'RECONNECT_BACKOFF_MAX_POWER=%q\n' "${reconnect_backoff_max_power}"
  printf 'WORKER_IDLE_SLEEP_MS=%q\n' "${worker_idle_sleep_ms}"
  printf 'WORKER_RECV_TIMEOUT_MS=%q\n' "${worker_recv_timeout_ms}"
  printf 'WORKER_MAX_SLICE_MS=%q\n' "${worker_max_slice_ms}"
  printf 'WORKER_SLICE_CHECK_INTERVAL=%q\n' "${worker_slice_check_interval}"
  printf 'WORKER_ACTIVE_POLL_INTERVAL=%q\n' "${worker_active_poll_interval}"
  printf 'WORKER_STATS_FLUSH_THRESHOLD=%q\n' "${worker_stats_flush_threshold}"
  printf 'WORKER_STATS_FLUSH_INTERVAL_MS=%q\n' "${worker_stats_flush_interval_ms}"
  printf 'CPU_BATCH_BASE=%q\n' "${cpu_batch_base}"
  printf 'CPU_BATCH_MIN=%q\n' "${cpu_batch_min}"
  printf 'CPU_BATCH_MAX=%q\n' "${cpu_batch_max}"
  printf 'CPU_BATCH_SIZE=%q\n' "${cpu_batch_size}"
  printf 'GPU_BATCH_BASE=%q\n' "${gpu_batch_base}"
  printf 'GPU_BATCH_MIN=%q\n' "${gpu_batch_min}"
  printf 'GPU_BATCH_MAX=%q\n' "${gpu_batch_max}"
  printf 'OPENCL_BATCH_SIZE=%q\n' "${opencl_batch_size}"
  printf 'OPENCL_LOCAL_WORK_SIZE=%q\n' "${opencl_local_work_size}"
  printf 'AUTOLYKOS_BLOCK_SIZE=%q\n' "${autolykos_block_size}"
  printf 'OPENCL_AUTOTUNE=%q\n' "${opencl_autotune}"
  printf 'CUDA_BATCH_SIZE=%q\n' "${cuda_batch_size}"
  printf 'CUDA_BLOCK_SIZE=%q\n' "${cuda_block_size}"
  printf 'CUDA_AUTOTUNE=%q\n' "${cuda_autotune}"
  printf 'CPU_AUTOTUNE=%q\n' "${cpu_autotune}"
  printf 'CPU_AUTOTUNE_PROBE_MS=%q\n' "${cpu_autotune_probe_ms}"
  printf 'GPU_AUTOTUNE_ROUNDS=%q\n' "${gpu_autotune_rounds}"
  printf 'HIVE_STATS_PATH=%q\n' "${hive_stats_path}"
  printf 'HIVE_STATS_DISABLED=%q\n' "${hive_stats_disabled}"
} > "${CUSTOM_CONFIG_FILENAME}"

echo "Generated ${CUSTOM_CONFIG_FILENAME} for ${CUSTOM_NAME}"

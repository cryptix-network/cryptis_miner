#!/usr/bin/env bash
set -euo pipefail

DEVICE_NUM="${1:-0}"
LOG_FILE="${2:-}"
export DEVICE_NUM LOG_FILE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
if [[ -f "${SCRIPT_DIR}/mmp-external.conf" ]]; then
  source "${SCRIPT_DIR}/mmp-external.conf"
fi

EXTERNAL_NAME="${EXTERNAL_NAME:-cryptis-miner}"
EXTERNAL_VERSION="${EXTERNAL_VERSION:-1.0.1}"

runtime_state="${MMP_RUNTIME_CONFIG:-/tmp/cryptis-miner-mmpos-runtime.conf}"
# shellcheck disable=SC1090
if [[ -f "${runtime_state}" ]]; then
  source "${runtime_state}"
fi

api_bind="${API_BIND:-127.0.0.1}"
api_port="${API_PORT:-48673}"
api_token="${API_TOKEN:-}"
hive_stats_path="${HIVE_STATS_PATH:-/hiveos/stats}"

if [[ "${hive_stats_path}" != /* ]]; then
  hive_stats_path="/${hive_stats_path}"
fi

endpoint="${MMP_STATS_ENDPOINT:-http://${api_bind}:${api_port}${hive_stats_path}}"
fallback_endpoint="${MMP_FALLBACK_STATS_ENDPOINT:-http://${api_bind}:${api_port}/api/v1/stats}"

emit_zero() {
  printf '{"busid":[0],"hash":[0],"units":"khs","air":[0,0,0],"miner_name":"%s","miner_version":"%s"}\n' \
    "${EXTERNAL_NAME}" "${EXTERNAL_VERSION}"
}

fetch_json() {
  local url="$1"
  if [[ -n "${api_token}" ]]; then
    curl -fsS --connect-timeout 2 --max-time 3 \
      -H "Authorization: Bearer ${api_token}" \
      "${url}" 2>/dev/null || true
  else
    curl -fsS --connect-timeout 2 --max-time 3 "${url}" 2>/dev/null || true
  fi
}

response="$(fetch_json "${endpoint}")"
if [[ -z "${response}" && "${fallback_endpoint}" != "${endpoint}" ]]; then
  response="$(fetch_json "${fallback_endpoint}")"
fi

if [[ -z "${response}" ]]; then
  emit_zero
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  emit_zero
  exit 0
fi

stats_json="$(
  jq -c --arg miner_name "${EXTERNAL_NAME}" --arg miner_version "${EXTERNAL_VERSION}" '
    def round2: ((. * 100.0) | round) / 100.0;
    def u32:
      if . == null then 0
      else (if type == "number" then . else (tonumber? // 0) end)
      | if . < 0 then 0 else round end
      end;
    def h_khs:
      if . == null then 0
      else (if type == "number" then . else (tonumber? // 0) end)
      | (. / 1000.0)
      | round2
      end;
    def pad0($n):
      if length >= $n then .[0:$n] else . + ([range(length; $n)] | map(0)) end;
    def normalize_bus:
      map(
        if . == -1 or . == "-1" then "cpu"
        elif . == null then 0
        else .
        end
      );

    if (has("stats") and (.stats | type == "object")) then
      (.stats.hs // [(.khs // 0)]) as $hash_raw
      | ($hash_raw | map(if . == null then 0 else . end)) as $hash
      | ($hash | length) as $n
      | (.stats.bus_numbers // []) as $bus_raw
      | ($bus_raw | normalize_bus) as $bus_norm
      | ($bus_norm | if length == 0 then [range(0; $n)] else . end) as $bus
      | (.stats.temp // []) as $temp
      | (.stats.fan // []) as $fan
      | (.stats.power // []) as $power
      | (.stats.ar // [0,0]) as $ar
      | {
          busid: ($bus | pad0($n)),
          hash: ($hash | pad0($n)),
          units: (.stats.hs_units // "khs"),
          air: [
            ($ar[0] // 0),
            0,
            ($ar[1] // 0)
          ],
          temp: (($temp | map(u32) | pad0($n))),
          fan: (($fan | map(u32) | pad0($n))),
          watt: (($power | map(u32) | pad0($n))),
          miner_name: $miner_name,
          miner_version: $miner_version
        }
    else
      . as $root
      | ($root.performance.devices.cpu // []) as $cpu
      | ($root.performance.devices.gpu // []) as $gpu
      | ($cpu | map(.hashrate_hs | h_khs)) as $cpu_hash
      | ($gpu | map(.hashrate_hs | h_khs)) as $gpu_hash
      | (($cpu_hash + $gpu_hash)) as $combined_hash
      | ($combined_hash | if length == 0 then [(($root.performance.hashrate_hs.current_total // $root.hashrate_hs.total // 0) / 1000 | round2)] else . end) as $hash
      | ($hash | length) as $n
      | ($cpu | map("cpu")) as $cpu_bus
      | ($gpu | map(.device_index // 0)) as $gpu_bus
      | (($cpu_bus + $gpu_bus) | if length == 0 then [0] else . end) as $bus
      | ($cpu | map(0)) as $cpu_temp
      | ($cpu | map(0)) as $cpu_fan
      | ($cpu | map(0)) as $cpu_watt
      | ($gpu | map(.temperature_c | u32)) as $gpu_temp
      | ($gpu | map(.fan_percent | u32)) as $gpu_fan
      | ($gpu | map(.power_watts | u32)) as $gpu_watt
      | (($root.shares.rejected // 0) + ($root.shares.duplicate // 0) + ($root.shares.dropped_local // 0)) as $rej
      | {
          busid: (($bus | normalize_bus | pad0($n))),
          hash: ($hash | pad0($n)),
          units: "khs",
          air: [($root.shares.accepted // 0), 0, $rej],
          temp: (($cpu_temp + $gpu_temp) | pad0($n)),
          fan: (($cpu_fan + $gpu_fan) | pad0($n)),
          watt: (($cpu_watt + $gpu_watt) | pad0($n)),
          miner_name: $miner_name,
          miner_version: $miner_version
        }
    end
  ' <<< "${response}" 2>/dev/null || true
)"

if [[ -z "${stats_json}" || "${stats_json}" == "null" ]]; then
  emit_zero
  exit 0
fi

echo "${stats_json}"

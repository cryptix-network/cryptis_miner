#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/h-manifest.conf"

if [[ -f "${CUSTOM_CONFIG_FILENAME}" ]]; then
  # shellcheck disable=SC1090
  source "${CUSTOM_CONFIG_FILENAME}"
fi

api_bind="${API_BIND:-127.0.0.1}"
api_port="${API_PORT:-48673}"
hive_stats_path="${HIVE_STATS_PATH:-/hiveos/stats}"
api_token="${API_TOKEN:-}"
if [[ "${hive_stats_path}" != /* ]]; then
  hive_stats_path="/${hive_stats_path}"
fi

endpoint="${CUSTOM_STATS_ENDPOINT:-http://${api_bind}:${api_port}${hive_stats_path}}"
fallback_endpoint="${CUSTOM_FALLBACK_STATS_ENDPOINT:-http://${api_bind}:${api_port}/api/v1/stats}"

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
  khs=0
  stats="{}"
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  if jq -e 'has("stats") and (has("khs") or has("hashrate_hs"))' >/dev/null 2>&1 <<< "${response}"; then
    khs="$(jq -r '.khs // (((.hashrate_hs.total // 0) / 1000) | floor)' <<< "${response}" 2>/dev/null || echo 0)"
    stats="$(jq -c '.stats // {}' <<< "${response}" 2>/dev/null || echo '{}')"
  else
    khs="$(jq -r '((.performance.hashrate_hs.current_total // .hashrate_hs.total // 0) / 1000) | floor' <<< "${response}" 2>/dev/null || echo 0)"
    stats="$(
      jq -c '
        def round2: ((. * 100.0) | round) / 100.0;
        def u32: if . == null then 0 else (. | if . < 0 then 0 else round end) end;
        def khs: (((.hashrate_hs // 0) / 1000) | round2);
        . as $root
        | ($root.performance.devices.cpu // []) as $cpu
        | ($root.performance.devices.gpu // []) as $gpu
        | ($cpu | map(khs)) as $cpu_hs
        | ($gpu | map(khs)) as $gpu_hs
        | ($gpu | map((.temperature_c // 0) | u32)) as $temp
        | ($gpu | map((.fan_percent // 0) | u32)) as $fan
        | ($gpu | map((.power_watts // 0) | u32)) as $power
        | ($cpu | map(-1)) as $cpu_bus
        | ($gpu | map(.device_index // 0)) as $gpu_bus
        | {
            hs: (($cpu_hs + $gpu_hs) | if length == 0 then [((($root.performance.hashrate_hs.current_total // 0) / 1000) | round2)] else . end),
            hs_units: "khs",
            temp: $temp,
            fan: $fan,
            power: $power,
            uptime: ($root.runtime.uptime_seconds // $root.uptime_seconds // 0),
            ar: [
              ($root.shares.accepted // 0),
              (($root.shares.rejected // 0) + ($root.shares.duplicate // 0) + ($root.shares.dropped_local // 0))
            ],
            algo: ($root.miner.algorithm // $root.algorithm // "unknown"),
            ver: ($root.version // "unknown"),
            bus_numbers: ($cpu_bus + $gpu_bus)
          }
      ' <<< "${response}" 2>/dev/null || echo '{}'
    )"
  fi
else
  khs=0
  stats="{}"
fi

# Cryptis Miner API (Developer Reference)

Short, practical reference for all API surfaces.

## 1) API Overview

- **REST API (direct):** `http://127.0.0.1:48673`
- **Frontend server:** `http://127.0.0.1:8943`
- **Frontend API bridge:** `http://127.0.0.1:8943/api/*`
- **Hive-compatible output (REST):** `/api/v1/hive` and (by default) `/hiveos/stats`

Notes:
- Hive stats use the **same REST port** as the main REST API.
- REST API supports `GET` only.
- Frontend server supports `GET` and `POST` (`/login`, `/logout`).
- Active target values in payloads (for example `algo`) can be `cryptix-ox8`, `randomx`, or `autolykosv2`.
- Hive-compatible `khs` values are normalized from H/s for every supported algorithm.

## 2) Security and Access

### REST API

Configured in `[api]` (`configs/default.toml`):
- `auth_token` (optional Bearer token)
- `allowed_ips` (optional IP allowlist)
- `rate_limit_per_minute` (optional per-IP limit)

Behavior:
- Missing/invalid token: `401 Unauthorized`
- IP not allowed: `403 Forbidden`
- Rate limit exceeded: `429 Too Many Requests`

Auth header (when `auth_token` is set):

```http
Authorization: Bearer <TOKEN>
```

### Frontend API (`/api/*` on frontend port)

Configured in `[frontend]`:
- `password_enabled`
- `password`
- `rate_limit_per_minute`
- `logs_enabled` (controls `/api/logs` visibility; also requires `logging.file`)

If password mode is enabled:
- `POST /login` with `{"password":"..."}` sets an auth cookie
- `POST /logout` clears the cookie
- Calls to `/api/*` without a valid cookie return `401 Unauthorized`

## 3) Endpoints

## REST API (`:48673`)

- `GET /`
- `GET /health`
- `GET /api/v1/health`
- `GET /stats`
- `GET /api/v1/stats`
- `GET /api/v1/telemetry`
- `GET /api/v1/system`
- `GET /api/v1/devices`
- `GET /api/v1/hive`
- `GET <hive_stats_path>` (default: `/hiveos/stats`)

## Frontend API Bridge (`:8943/api/*`)

- `GET /api/health` -> health snapshot
- `GET /api/stats` -> stats snapshot
- `GET /api/telemetry` -> telemetry snapshot
- `GET /api/system` -> system snapshot
- `GET /api/devices` -> devices snapshot
- `GET /api/hive` -> hive snapshot
- `GET /api/logs` -> frontend log snapshot (last 50 lines, 5s refresh hint)

Extra frontend routes:
- `POST /login`
- `POST /logout`

## 4) Response Shapes (compact)

Notes:
- Sensor fields may be `null` if unavailable.
- Units are encoded in field names (`*_hs`, `*_watts`, `*_ms`, etc.).
- Payloads can grow between releases; clients should ignore unknown fields.

### `GET /api/v1/health`

```json
{
  "status": "ok|degraded",
  "pool_connected": true,
  "uptime_seconds": 1234,
  "timestamp_unix": 1700000000,
  "version": "x.y.z"
}
```

### `GET /api/v1/stats` (primary endpoint)

```json
{
  "version": "x.y.z",
  "timestamp_unix": 1700000000,
  "environment": {
    "runtime_environment": "native|hiveos|...",
    "os": "windows|linux|...",
    "arch": "x86_64|...",
    "arch_display": "...",
    "cpu_vendor": "...",
    "gpu_runtime": "cuda|opencl|cuda+opencl|none",
    "gpu_detected_devices": 1,
    "gpu_detected_vendors": ["NVIDIA"]
  },
  "api": {
    "bind_address": "127.0.0.1",
    "port": 48673,
    "hive_stats_enabled": true,
    "hive_stats_path": "/hiveos/stats"
  },
  "runtime": {
    "started_at_unix": 1700000000,
    "uptime_seconds": 1234,
    "pid": 12345
  },
  "miner": {
    "name": "cryptis-miner",
    "algorithm": "cryptix-ox8",
    "mining_mode": "cpu|gpu|hybrid|none",
    "worker_name": "worker1",
    "threads": { "configured": 10, "active": 10 },
    "gpu_devices_configured": [0],
    "intensity": 1.0,
    "overclock": {
      "enabled": false,
      "apply_on_start": true,
      "fail_on_error": false,
      "dry_run": false,
      "timeout_ms": 8000,
      "command_counts": { "all": 0, "nvidia": 0, "amd": 0, "intel": 0 },
      "commands": { "all": [], "nvidia": [], "amd": [], "intel": [] }
    }
  },
  "pool": {
    "url": "stratum+tcp://...",
    "stratum_protocol": "v1|v2",
    "connected": true,
    "difficulty": 1.0,
    "last_job_id": "...",
    "last_job_age_seconds": 2
  },
  "performance": {
    "hashrate_hs": { "current_total": 0, "average_total": 0, "cpu": 0, "gpu": 0 },
    "power": { "gpu_total_watts": 123.4 },
    "efficiency": { "gpu_kh_per_w": 250.5, "total_kh_per_w": 250.5 },
    "devices": { "cpu": [], "gpu": [], "all": [] },
    "total_hashes": 0
  },
  "network": {
    "share_submit_latency_ms": {
      "last": 12.3,
      "average": 15.2,
      "samples": 42,
      "cpu": { "last": 10.1, "average": 12.0, "samples": 20 },
      "gpu": { "last": 16.5, "average": 18.1, "samples": 22 }
    }
  },
  "shares": {
    "accepted": 100,
    "rejected": 2,
    "duplicate": 1,
    "dropped_local": 0,
    "total_tracked": 103,
    "acceptance_rate_percent": 97.09,
    "sources": {
      "cpu": { "accepted": 0, "rejected": 0, "duplicate": 0, "dropped_local": 0, "rejected_total": 0 },
      "gpu": { "accepted": 100, "rejected": 2, "duplicate": 1, "dropped_local": 0, "rejected_total": 3 }
    }
  },
  "system": {}
}
```

### `GET /api/v1/devices`

```json
{
  "timestamp_unix": 1700000000,
  "version": "x.y.z",
  "counts": { "cpu": 1, "gpu": 1, "all": 2 },
  "power": { "gpu_total_watts": 123.4 },
  "devices": {
    "cpu": [
      {
        "id": "cpu",
        "type": "cpu",
        "name": "CPU",
        "hashrate_hs": 0,
        "threads": { "configured": 10, "active": 10 },
        "shares": { "accepted": 0, "rejected": 0, "duplicate": 0, "dropped_local": 0, "rejected_total": 0 }
      }
    ],
    "gpu": [
      {
        "id": "gpu-0",
        "type": "gpu",
        "device_index": 0,
        "name": "NVIDIA GeForce GTX 1080 Ti",
        "vendor": "NVIDIA",
        "backend": "cuda+opencl",
        "hashrate_hs": 0,
        "efficiency_kh_per_w": 0,
        "temperature_c": 69,
        "fan_percent": 33,
        "power_watts": 124.0,
        "core_clock_mhz": 1493,
        "memory_clock_mhz": 5508
      }
    ],
    "all": []
  }
}
```

### `GET /api/v1/system`

```json
{
  "timestamp_unix": 1700000000,
  "version": "x.y.z",
  "runtime": {
    "uptime_seconds": 1234,
    "pool_connected": true,
    "mining_mode": "gpu",
    "algorithm": "cryptix-ox8"
  },
  "platform": {
    "runtime_environment": "native",
    "os": "windows",
    "arch": "x86_64",
    "arch_display": "x86_64 (x64/amd64)",
    "cpu_vendor": "AMD",
    "gpu_runtime": "cuda+opencl",
    "gpu_detected_devices": 1,
    "gpu_detected_vendors": ["NVIDIA"]
  },
  "system": {
    "hostname": "...",
    "cpu": { "brand": "...", "vendor": "...", "logical_cores": 12, "average_usage_percent": 12.34 },
    "gpu": { "detected_devices": 1, "detected_vendors": ["NVIDIA"], "runtime": "cuda+opencl" },
    "memory": { "total_bytes": 0, "used_bytes": 0, "free_bytes": 0 },
    "load_average": { "one": 0, "five": 0, "fifteen": 0 }
  }
}
```

### `GET /api/v1/telemetry`

```json
{
  "timestamp_unix": 1700000000,
  "version": "x.y.z",
  "telemetry": {},
  "platform": {}
}
```

`telemetry` is the raw internal telemetry snapshot (large, detailed payload).

### `GET /api/v1/hive` (Hive-compatible)

```json
{
  "khs": 0.0,
  "api_version": 2,
  "hashrate_hs": { "total": 0, "cpu": 0, "gpu": 0 },
  "khs_breakdown": { "cpu": 0.0, "gpu": 0.0 },
  "uptime_seconds": 1234,
  "pool_connected": true,
  "shares": {},
  "stats": {
    "hs": [0.0],
    "hs_units": "khs",
    "temp": [0],
    "fan": [0],
    "power": [0],
    "uptime": 1234,
    "ar": [0, 0],
    "algo": "cryptix-ox8",
    "ver": "x.y.z",
    "bus_numbers": [0]
  }
}
```

Notes:
- `stats.algo` reflects the currently active mining target (for example `autolykosv2` on Ergo GPU mining).
- In hybrid mode, total values include both CPU and GPU contributions.

## 5) Error Format

Typical error object:

```json
{
  "error": "not_found|unauthorized|forbidden|too_many_requests|method_not_allowed|bad_request",
  "reason": "...",
  "path": "/requested/path"
}
```

## 6) Quick Examples

REST stats:

```bash
curl -s http://127.0.0.1:48673/api/v1/stats
```

REST stats with token:

```bash
curl -s -H "Authorization: Bearer <TOKEN>" http://127.0.0.1:48673/api/v1/stats
```

Frontend login + stats:

```bash
curl -i -X POST http://127.0.0.1:8943/login -H "Content-Type: application/json" -d "{\"password\":\"<PASS>\"}"
curl -s http://127.0.0.1:8943/api/stats --cookie "cryptis_frontend_auth=<COOKIE_VALUE>"
```

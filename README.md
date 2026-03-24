# Cryptis Miner

Cryptis Miner is a performance-oriented miner designed for real multi-device rigs.  
It focuses on broad hardware compatibility, stable operation, and practical tuning for production mining setups.

- Website: https://cryptis-miner.cryptix-network.org/
- Public Benchmarks: https://cryptis-miner.cryptix-network.org/bench
- Benchmark API: https://cryptis-miner.cryptix-network.org/api/v1/overview

## Documentation Guide

- Installation/platform setup: [INSTALL.md](INSTALL.md)
- Batch starter scripts (Windows): [batch/README.md](tools/README_BAT.md)
- API reference: [API.md](API.md)
- Known issues: [BUGS.md](BUGS.md)

## Table of Contents

- [Currently Supported Targets](#currently-supported-targets)
- [What It Supports](#what-it-supports)
- [Supported Platforms](#supported-platforms)
- [Browser Dashboard](#browser-dashboard)
- [Quick Start](#quick-start)
- [Start Examples (Modes + Hash Targets)](#start-examples-modes--hash-targets)
- [Runtime Notes](#runtime-notes)
- [Frontend Runtime Notes](#frontend-runtime-notes)
- [CLI Reference (All Startup Arguments)](#cli-reference-all-startup-arguments)
- [API Endpoints](#api-endpoints)
- [Config File](#config-file)
- [Support](#support)

## Currently Supported Targets

- `cryptix + ox8` (CPU/GPU)
- `hoosat + hoohash` (CPU/GPU)
- `pepepow + hoohash` (CPU/GPU)
- `monero + randomx` (CPU-only)
- `zephyr + randomx` (CPU-only)
- `ergo + autolykosv2` (CPU/GPU)
- `unknown + ox8` (CPU/GPU)
- `unknown + hoohash` (CPU/GPU)
- `unknown + randomx` (CPU-only)
- `unknown + autolykosv2` (CPU/GPU)

GPU runtime supports:
- `ox8`
- `hoohash`
- `autolykosv2`

## What It Supports

- CPU-only mining
- GPU-only mining
- CPU + GPU hybrid mining
- Dual GPU lane mining on the same GPU set (core lane + memory lane)
- Triple mining (CPU + GPU core lane + GPU memory lane)
- Hybrid target overrides (`cpu-coin/cpu-hash` and `gpu-coin/gpu-hash`)
- Multi-CPU support
- Multi-GPU support
- Mixed GPU rigs (AMD + NVIDIA + Intel in one rig)

## Supported Platforms

Operating systems:

- Linux
- Windows
- HiveOS

Architectures:

- x64
- x86
- ARM

`macOS / Apple` is not supported in official releases.

## Browser Dashboard

Open `http://127.0.0.1:8943/` in your browser to access the embedded dashboard.

## Quick Start

Windows (CLI only):

```bash
cryptis-miner.exe --coin <COIN> --hash <HASH> --pool stratum+tcp://pool.example.com:3333 --wallet <WALLET>
```

Linux / HiveOS (CLI only):

```bash
./cryptis-miner --coin <COIN> --hash <HASH> --pool stratum+tcp://pool.example.com:3333 --wallet <WALLET>
```

Windows (config file):

```bash
cryptis-miner.exe --config configs/default.toml mine
```

Linux / HiveOS (config file):

```bash
./cryptis-miner --config configs/default.toml mine
```

Check available targets on your binary:

```bash
cryptis-miner list-coins
cryptis-miner list-algorithms
```

## Start Examples (Modes + Hash Targets)

Replace placeholders first:

- `<POOL_URL>` example: `stratum+tcp://pool.example.com:3333`
- `<CPU_POOL_URL>` / `<GPU_POOL_URL>` for mixed-target hybrid mode
- `<WALLET>` = your wallet/login for the selected pool
- `<CPU_WALLET>` / `<GPU_WALLET>` for mixed-target hybrid mode
- `<WORKER>` = rig label

CPU-only:

```bash
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin cryptix --hash ox8 --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash ox8 --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin hoosat --hash hoohash --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin pepepow --hash hoohash --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash hoohash --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin monero --hash randomx --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin zephyr --hash randomx --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash randomx --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin ergo --hash autolykosv2 --no-gpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash autolykosv2 --no-gpu
```

GPU-only:

```bash
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin cryptix --hash ox8 --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash ox8 --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin hoosat --hash hoohash --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin pepepow --hash hoohash --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash hoohash --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin ergo --hash autolykosv2 --no-cpu
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash autolykosv2 --no-cpu
```

CPU+GPU hybrid:

```bash
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin cryptix --hash ox8
cryptis-miner.exe --pool <CPU_POOL_URL> --wallet <CPU_WALLET> --worker <WORKER> --password x --coin monero --hash randomx --cpu-pool <CPU_POOL_URL> --cpu-wallet <CPU_WALLET> --gpu-pool <GPU_POOL_URL> --gpu-wallet <GPU_WALLET> --gpu-password x --gpu-coin unknown --gpu-hash ox8
cryptis-miner.exe --pool <CPU_POOL_URL> --wallet <CPU_WALLET> --worker <WORKER> --password x --coin cryptix --hash ox8 --cpu-pool <CPU_POOL_URL> --cpu-wallet <CPU_WALLET> --gpu-pool <GPU_POOL_URL> --gpu-wallet <GPU_WALLET> --gpu-password x --gpu-coin ergo --gpu-hash autolykosv2
cryptis-miner.exe --pool <CPU_POOL_URL> --wallet <CPU_WALLET> --worker <WORKER> --password x --coin hoosat --hash hoohash --cpu-pool <CPU_POOL_URL> --cpu-wallet <CPU_WALLET> --gpu-pool <GPU_POOL_URL> --gpu-wallet <GPU_WALLET> --gpu-password x --gpu-coin unknown --gpu-hash ox8
cryptis-miner.exe --pool <POOL_URL> --wallet <WALLET> --worker <WORKER> --password x --coin unknown --hash hoohash --gpu-coin unknown --gpu-hash hoohash
```

Dual GPU lanes (same GPUs, OpenCL): core + memory

```bash
cryptis-miner.exe --pool <GPU_CORE_POOL_URL> --wallet <GPU_CORE_WALLET> --worker <WORKER> --password x --coin unknown --hash ox8 --no-cpu --gpu-backend opencl --gpu-core-coin unknown --gpu-core-hash ox8 --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool <GPU_CORE_POOL_URL> --gpu-core-wallet <GPU_CORE_WALLET> --gpu-core-password x --gpu-memory-pool <GPU_MEMORY_POOL_URL> --gpu-memory-wallet <GPU_MEMORY_WALLET> --gpu-memory-password x --gpu-core-intensity 0.55 --gpu-memory-intensity 0.45
cryptis-miner.exe --pool <GPU_CORE_POOL_URL> --wallet <GPU_CORE_WALLET> --worker <WORKER> --password x --coin unknown --hash hoohash --no-cpu --gpu-backend opencl --gpu-core-coin unknown --gpu-core-hash hoohash --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool <GPU_CORE_POOL_URL> --gpu-core-wallet <GPU_CORE_WALLET> --gpu-core-password x --gpu-memory-pool <GPU_MEMORY_POOL_URL> --gpu-memory-wallet <GPU_MEMORY_WALLET> --gpu-memory-password x --gpu-core-intensity 0.55 --gpu-memory-intensity 0.45
```

Triple mode (CPU + GPU core + GPU memory):

```bash
cryptis-miner.exe --pool <CPU_POOL_URL> --wallet <CPU_WALLET> --worker <WORKER> --password x --coin monero --hash randomx --cpu-pool <CPU_POOL_URL> --cpu-wallet <CPU_WALLET> --gpu-backend opencl --gpu-core-coin unknown --gpu-core-hash ox8 --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool <GPU_CORE_POOL_URL> --gpu-core-wallet <GPU_CORE_WALLET> --gpu-core-password x --gpu-memory-pool <GPU_MEMORY_POOL_URL> --gpu-memory-wallet <GPU_MEMORY_WALLET> --gpu-memory-password x --gpu-core-intensity 0.55 --gpu-memory-intensity 0.45
cryptis-miner.exe --pool <CPU_POOL_URL> --wallet <CPU_WALLET> --worker <WORKER> --password x --coin monero --hash randomx --cpu-pool <CPU_POOL_URL> --cpu-wallet <CPU_WALLET> --gpu-backend opencl --gpu-core-coin unknown --gpu-core-hash hoohash --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool <GPU_CORE_POOL_URL> --gpu-core-wallet <GPU_CORE_WALLET> --gpu-core-password x --gpu-memory-pool <GPU_MEMORY_POOL_URL> --gpu-memory-wallet <GPU_MEMORY_WALLET> --gpu-memory-password x --gpu-core-intensity 0.55 --gpu-memory-intensity 0.45
```

Windows starter scripts are in `batch/`:

- GPU script examples:
  - `batch/start-gpu-cryptix-ox8.bat`
  - `batch/start-gpu-hoosat-hoohash.bat`
  - `batch/start-gpu-pepepow-hoohash.bat`
  - `batch/start-gpu-unknown-hoohash.bat`
  - `batch/start-gpu-ergo-autolykosv2.bat`
  - `batch/start-gpu-unknown-autolykosv2.bat`
  - `batch/start-gpu-unknown-ox8.bat`

Hybrid naming format:

- `start-hybrid-<cpu-coin>-<cpu-hash>__<gpu-coin>-<gpu-hash>.bat`

Dual naming format:

- `start-dual-<gpu-core-coin>-<gpu-core-hash>__<gpu-memory-coin>-<gpu-memory-hash>.bat`

Triple naming format:

- `start-triple-<cpu-coin>-<cpu-hash>__<gpu-core-coin>-<gpu-core-hash>__<gpu-memory-coin>-<gpu-memory-hash>.bat`

Examples:

- `start-hybrid-cryptix-ox8__ergo-autolykosv2.bat`
- `start-hybrid-monero-randomx__unknown-ox8.bat`
- `start-hybrid-hoosat-hoohash__hoosat-hoohash.bat`
- `start-hybrid-unknown-hoohash__unknown-hoohash.bat`
- `start-hybrid-cryptix-ox8__unknown-ox8.bat`
- `start-dual-unknown-ox8__unknown-autolykosv2.bat`
- `start-triple-monero-randomx__unknown-ox8__unknown-autolykosv2.bat`

Hybrid script note:

- Same-target hybrid (`ox8+ox8`) can use one pool setup.
- Mixed-target hybrid (for example `CPU randomx + GPU ox8` or `CPU ox8 + GPU autolykosv2`) requires separate endpoint sets for CPU and GPU, including failovers.
- Use `--cpu-pool`/`--gpu-pool` and optional `--cpu-failover-pools`/`--gpu-failover-pools`.

## Runtime Notes

- CLI options override values from `--config`.
- GPU routing works for mixed rigs via `--gpu-devices`, `--cuda-devices`, and `--opencl-devices`.
- Inspect detected devices with `cryptis-miner device-inventory`.
- In `auto` mode, backend selection follows runtime availability:
  - `ox8`: CUDA/OpenCL based on runtime/device routing.
  - `autolykosv2`: NVIDIA prefers CUDA only when CUDA hash path is active (`--cuda-experimental`), otherwise OpenCL fallback is used; AMD/Intel use OpenCL.
- OpenCL hashing is available and recommended for production hashrate right now.
- CUDA hashing can be enabled for testing with `--cuda-experimental` (usually together with `--cuda`).
- CUDA experimental mode is currently for validation/testing only; CUDA kernel acceleration/tuning is not finished yet.
- RandomX accepts `--stratum-protocol v2`; this uses the RandomX compatibility login/job/submit workflow for pools that expose RandomX over a v2 profile.
- Default CUDA experimental state is controlled by `CUDA_HASHING_EXPERIMENTAL_ENABLED` in `src/mining/gpu/cuda.rs`; `--cuda-experimental` overrides it at runtime.
- Mixed rigs can run OpenCL + CUDA together when `cuda_devices` and `opencl_devices` are set to disjoint GPU id lists.
- In hybrid mode with different targets, overlapping CPU/GPU pool endpoint sets are rejected at startup (must be separated by target).
- Dual/triple lane mode is available via `--gpu-core-*` + `--gpu-memory-*` and currently runs in OpenCL lane mode (both lanes are forced to OpenCL in this release).
- Current dual/triple hash pairs for production are `gpu-core=ox8` + `gpu-memory=autolykosv2` and `gpu-core=hoohash` + `gpu-memory=autolykosv2` (the `hoohash` pair is OpenCL-only in this release; other pairs keep GPU core active and disable memory lane).
- GPU launch autotune is globally serialized across lanes/process workers in one miner instance, so dual/triple startup tuning runs one-at-a-time instead of competing on the same GPUs.
- In dual/triple mode with different targets, overlapping pool endpoint sets across active lanes are rejected at startup (CPU, GPU core, GPU memory).
- Hybrid CPU core reservation is configurable in `[mining.runtime]`:
  - `hybrid_cpu_reserve_min_cores`
  - `hybrid_cpu_reserve_max_cores`
  - `hybrid_cpu_reserve_gpu_threshold`
- CPU-only system-core reservation is configurable in `[mining.runtime]`:
  - `cpu_only_reserve_system_core` (default: `true`)
  - `cpu_only_reserved_cores` (default: `1`)
- Pool reconnect budgets:
  - `pool.retry_count` (default: `50`)
  - `pool.failover_retry_count` (default: `0` = unlimited)
- Per-hash GPU share policy is configurable in `[mining.runtime.gpu_hash_policies.<hash>]`:
  - `cpu_verify`
  - `opencl_mad_enable`
  - `opencl_native_math_enable` (experimental)
  - `opencl_fp_contract_disable` (hoohash-only)
  - `opencl_accuracy_boost` (experimental, hoohash-only, requires `cpu_verify=true`)
  - `cuda_strict_math_enable` (hoohash-only)
  - `strict_kernel_verify` (hoohash-only)
  - `strict_job`
  - `recent_job_max_ids`
  - `recent_job_max_age_ms`
  - Default policy:
    - `ox8`: `cpu_verify=false`, `strict_job=false`, window `64 / 8000ms`
    - `hoohash`: `cpu_verify=true`, `opencl_fp_contract_disable=true`, `cuda_strict_math_enable=true`, `strict_kernel_verify=false`, `strict_job=false`, window `640 / 1000ms`
    - `autolykosv2`: `cpu_verify=false`, `strict_job=true`
- HooHash OpenCL tuning:
  - `opencl_native_math_enable=false` by default; can increase speed but may reduce CPU-verified share accuracy.
  - `opencl_fp_contract_disable=true` by default; reduces FMA/contraction variance between OpenCL compilers.
  - `opencl_accuracy_boost=false` by default; can improve accepted-share quality near precision boundaries at the cost of extra CPU verify work.
- HooHash CUDA tuning:
  - `cuda_strict_math_enable=true` by default; uses stricter FP compile flags to reduce GPU/CPU drift.
  - `strict_kernel_verify=false` by default; enabling it enforces strict GPU-vs-CPU startup parity checks and may reject unstable device/driver combos.
- HiveOS wrapper keys for the same behavior:
  - `HYBRID_CPU_RESERVE_MIN_CORES`
  - `HYBRID_CPU_RESERVE_MAX_CORES`
  - `HYBRID_CPU_RESERVE_GPU_THRESHOLD`
  - `CPU_ONLY_RESERVE_SYSTEM_CORE`
  - `CPU_ONLY_RESERVED_CORES`
  - `GPU_CPU_VERIFY` (for example `ox8=off,hoohash=on,autolykosv2=off`)
  - `GPU_OPENCL_MAD_ENABLE` (for example `hoohash=off`)
  - `GPU_OPENCL_NATIVE_MATH_ENABLE` (for example `hoohash=off`)
  - `GPU_OPENCL_ACCURACY_BOOST` (for example `hoohash=on`)
  - `GPU_STRICT_JOB` (for example `ox8=off,hoohash=off,autolykosv2=on`)
  - `GPU_RECENT_JOB_MAX_IDS` (for example `hoohash=640`)
  - `GPU_RECENT_JOB_MAX_AGE_MS` (for example `hoohash=1000`)
- Optional benchmark telemetry uploads only performance/tuning metadata (hashrate, efficiency, temperatures, clocks, batch/autotune/backend/OC settings). No wallet/private-key secrets are sent.
- `--coin unknown` disables coin-specific wallet validation while benchmark telemetry/insights remain available
- CPU mining supports `ox8`, `hoohash`, `randomx`, and `autolykosv2`.
- `--gpu-hash autolykosv2`: NVIDIA runs via CUDA, AMD/Intel runs via OpenCL
- Autolykos block tuning can be pinned with `--autolykos-block-size <N>` or `mining.runtime.autolykos_block_size` (`>=64`, divisible by `8`).
## Frontend Runtime Notes

- Embedded dashboard is enabled by default.
- Default URL: `http://127.0.0.1:8943/`
- Miner log pane uses `logging.file` and shows the latest 50 lines with a 5s refresh.
- Frontend log endpoint: `GET /api/logs` (on frontend port)
- Main options:
  - `--frontend-disabled`
  - `--frontend-logs-enabled`
  - `--frontend-logs-disabled`
  - `--frontend-bind`
  - `--frontend-port`
  - `--frontend-password-enabled`
  - `--frontend-password`
  - `--frontend-rate-limit-per-minute`
- Config toggle: `frontend.logs_enabled = true|false` (default: `true`)
- HiveOS wrapper toggle: `FRONTEND_LOGS_DISABLED:1` (in `CUSTOM_URL`) or `CUSTOM_FRONTEND_LOGS_DISABLED=1`

## CLI Reference (All Startup Arguments)

Usage:

```bash
cryptis-miner [OPTIONS] [COMMAND]
```

Always check your local binary help for the latest live output:

```bash
cryptis-miner --help
cryptis-miner <COMMAND> --help
```

### Commands

- `mine` - start mining (default when command is omitted)
- `benchmark` - run benchmark mode
  - `--duration <SECONDS>` - benchmark duration
  - `--coin <COIN>` - benchmark coin target
  - `--hash <HASH>` - benchmark hash target
  - `--algorithm <NAME>` - hidden legacy selector
- `list-algorithms` - print supported algorithms
- `list-coins` - print supported coins
- `compatibility` - print runtime compatibility matrix
- `device-inventory` - print detected GPUs and CUDA/OpenCL visibility
- `config generate --output <FILE>` - generate default config
- `config validate --file <FILE>` - validate a config file
- `config show` - print current effective config as JSON

### Target and Pool

- `--coin <COIN>` - coin target
- `--hash <HASH>` - hash family target
- `--cpu-coin <COIN>` - CPU target coin override
- `--cpu-hash <HASH>` - CPU target hash override
- `--gpu-coin <COIN>` - GPU target coin override
- `--gpu-hash <HASH>` - GPU target hash override (`ox8`, `hoohash`, or `autolykosv2`)
- `--gpu-core-coin <COIN>` - GPU core-lane coin override (dual/triple)
- `--gpu-core-hash <HASH>` - GPU core-lane hash override (dual/triple supports `ox8` and `hoohash`; `hoohash` core pair currently requires OpenCL)
- `--gpu-memory-coin <COIN>` - GPU memory-lane coin override (dual/triple)
- `--gpu-memory-hash <HASH>` - GPU memory-lane hash override (dual/triple currently expects `autolykosv2`)
- `-a, --algorithm <NAME>` - hidden legacy selector (compatibility only)
- `-p, --pool <URL>` - pool URL (`stratum+tcp://...` or `stratum+ssl://...`)
- `--cpu-pool <URL>` - CPU pool URL override
- `--cpu-failover-pools <URLS>` - CPU failover pools (comma-separated)
- `--cpu-stratum-protocol <v1|v2>` - CPU Stratum protocol override
- `--cpu-user <USER>` - CPU pool login override
- `--cpu-password <PASS>` - CPU pool password override
- `--cpu-wallet <WALLET>` - CPU wallet override
- `--gpu-pool <URL>` - GPU pool URL override
- `--gpu-failover-pools <URLS>` - GPU failover pools (comma-separated)
- `--gpu-stratum-protocol <v1|v2>` - GPU Stratum protocol override
- `--gpu-user <USER>` - GPU pool login override
- `--gpu-password <PASS>` - GPU pool password override
- `--gpu-wallet <WALLET>` - GPU wallet override
- `--gpu-core-pool <URL>` - GPU core-lane pool URL override
- `--gpu-core-failover-pools <URLS>` - GPU core-lane failover pools (comma-separated)
- `--gpu-core-stratum-protocol <v1|v2>` - GPU core-lane Stratum protocol override
- `--gpu-core-user <USER>` - GPU core-lane pool login override
- `--gpu-core-password <PASS>` - GPU core-lane pool password override
- `--gpu-core-wallet <WALLET>` - GPU core-lane wallet override
- `--gpu-memory-pool <URL>` - GPU memory-lane pool URL override
- `--gpu-memory-failover-pools <URLS>` - GPU memory-lane failover pools (comma-separated)
- `--gpu-memory-stratum-protocol <v1|v2>` - GPU memory-lane Stratum protocol override
- `--gpu-memory-user <USER>` - GPU memory-lane pool login override
- `--gpu-memory-password <PASS>` - GPU memory-lane pool password override
- `--gpu-memory-wallet <WALLET>` - GPU memory-lane wallet override
- `--stratum-protocol <v1|v2>` - Stratum protocol version
- `--stratum-protocol-fallback` / `--no-stratum-protocol-fallback` - try v1<->v2 fallback on protocol connect/authorize failure
- `--stratum-transport <auto|tcp|tls>` - transport mode
- `--stratum-transport-fallback` / `--no-stratum-transport-fallback` - try TCP<->TLS fallback when connect/handshake fails
- `--pool-retry-count <N>` - reconnect attempts (`0` = unlimited)
- `--pool-retry-delay-ms <MS>` - reconnect base delay
- `--pool-connect-timeout-ms <MS>` - TCP connect timeout
- `--pool-tls-timeout-ms <MS>` - TLS handshake timeout
- `--pool-tls-verify-cert` / `--pool-tls-no-verify-cert` - enable or disable TLS certificate+hostname verification
- `--pool-request-timeout-ms <MS>` - Stratum request timeout
- `--pool-job-channel-size <N>` - internal pool job queue size

### Identity and Auth

- `-u, --user <USER>` - pool login user
- `-P, --password <PASS>` - pool password
- `-w, --wallet <WALLET>` - wallet address
- `-n, --worker <NAME>` - worker name
- `--rig-label <NAME>` - alias for worker label

### CPU and GPU Routing

- `-t, --threads <N>` - CPU thread count
- `--cpu-only-reserve-system-core` / `--no-cpu-only-reserve-system-core` - toggle CPU-only system-core reservation
- `--cpu-only-reserved-cores <N>` - reserved logical core count in CPU-only mode
- `--cpu-affinity <IDS>` - bind CPU workers to core IDs (comma-separated)
- `--no-cpu` - disable CPU mining
- `--no-gpu` - disable GPU mining
- `--gpu-devices <IDS>` - selected GPU IDs (comma-separated)
- `--cuda-devices <IDS>` - force selected GPU IDs to CUDA
- `--opencl-devices <IDS>` - force selected GPU IDs to OpenCL
- `--disable-gpu-amd` - skip AMD GPUs
- `--disable-gpu-nvidia` - skip NVIDIA GPUs
- `--disable-gpu-intel` - skip Intel GPUs

### Intensity and Batch Sizing

- `--intensity <X>` - global intensity fallback (CPU + GPU)
- `--intensity-min <X>` - lower clamp for effective intensity
- `--intensity-max <X>` - upper clamp for effective intensity
- `--cpu-intensity <X>` - CPU intensity override
- `--gpu-intensity <X>` - GPU intensity override
- `--gpu-core-intensity <X>` - GPU core-lane intensity override (dual/triple)
- `--gpu-memory-intensity <X>` - GPU memory-lane intensity override (dual/triple)
- `--cpu-batch-base <N>` - CPU batch baseline
- `--cpu-batch-min <N>` - CPU batch minimum
- `--cpu-batch-max <N>` - CPU batch maximum
- `--cpu-batch-size <N>` - fixed CPU batch override
- `--gpu-batch-base <N>` - GPU batch baseline
- `--gpu-batch-min <N>` - GPU batch minimum
- `--gpu-batch-max <N>` - GPU batch maximum
- `--opencl-batch-size <N>` - fixed OpenCL batch override
- `--opencl-local-work-size <N>` - fixed OpenCL local work size
- `--autolykos-block-size <N>` - Autolykos-only GPU block size override (OpenCL + CUDA)
- `--cuda-batch-size <N>` - fixed CUDA batch override
- `--cuda-block-size <N>` - fixed CUDA block size (threads per block)

### Autotune

- `--opencl-autotune` / `--no-opencl-autotune` - enable or disable OpenCL startup autotune
- `--cuda-autotune` / `--no-cuda-autotune` - enable or disable CUDA startup autotune
- `--cpu-autotune` / `--no-cpu-autotune` - enable or disable CPU startup autotune
- `--cpu-autotune-probe-ms <MS>` - CPU autotune probe duration
- `--gpu-autotune-rounds <N>` - rounds per GPU candidate (median scoring)

Autotune behavior:

- CPU autotune ON: startup selects CPU batch size automatically.
- CPU autotune OFF: `cpu_batch_size` is used if set; otherwise defaults are computed.
- OpenCL autotune ON: startup selects OpenCL launch values automatically.
- OpenCL autotune OFF: manual OpenCL launch values are used if set.
- CUDA autotune ON: startup selects CUDA block size and batch size automatically.
- CUDA autotune OFF: manual CUDA launch values are used if set.

### Runtime and Queue Control

- `--share-submit-rate <N>` - max submit rate (shares per second)
- `--share-submit-burst <N>` - submit burst budget
- `--share-queue-capacity <N>` - submit queue capacity
- `--recent-job-max-ids <N>` - recent-job cache size
- `--recent-job-max-age-ms <MS>` - recent-job cache max age
- `--gpu-cpu-verify <HASH=BOOL[,HASH=BOOL...]>` - per-hash GPU CPU-verify toggle (`ox8|hoohash|autolykosv2`)
- `--gpu-opencl-mad-enable <HASH=BOOL[,HASH=BOOL...]>` - per-hash OpenCL MAD toggle (`ox8|hoohash|autolykosv2`)
- `--gpu-opencl-native-math-enable <HASH=BOOL[,HASH=BOOL...]>` - per-hash experimental native OpenCL math toggle (`ox8|hoohash|autolykosv2`)
- `--gpu-opencl-fp-contract-disable <HASH=BOOL[,HASH=BOOL...]>` - hoohash-only OpenCL FP contraction control (`hoohash`)
- `--gpu-opencl-accuracy-boost <HASH=BOOL[,HASH=BOOL...]>` - per-hash experimental OpenCL accuracy boost (`hoohash` only, requires CPU verify)
- `--gpu-cuda-strict-math-enable <HASH=BOOL[,HASH=BOOL...]>` - hoohash-only CUDA strict FP compile toggle (`hoohash`)
- `--gpu-strict-kernel-verify <HASH=BOOL[,HASH=BOOL...]>` - hoohash-only strict GPU kernel parity verification toggle (`hoohash`)
- `--gpu-strict-job <HASH=BOOL[,HASH=BOOL...]>` - per-hash strict-job toggle (`on` = only latest job)
- `--gpu-recent-job-max-ids <HASH=N[,HASH=N...]>` - per-hash recent-job id window (used when strict-job is off)
- `--gpu-recent-job-max-age-ms <HASH=MS[,HASH=MS...]>` - per-hash recent-job age window in milliseconds (used when strict-job is off)
- `--job-recv-timeout-ms <MS>` - timeout for incoming jobs
- `--stats-interval-ms <MS>` - stats update interval
- `--gpu-status-board-interval-ms <MS>` - GPU status board interval (`0` disables)
- `--hybrid-cpu-reserve-min-cores <N>` - hybrid reserved CPU cores when GPU count is at/below threshold
- `--hybrid-cpu-reserve-max-cores <N>` - hybrid reserved CPU cores when GPU count is above threshold
- `--hybrid-cpu-reserve-gpu-threshold <N>` - GPU-count threshold used by hybrid reserve policy
- `--task-drain-timeout-ms <MS>` - graceful shutdown drain timeout
- `--shutdown-poll-ms <MS>` - shutdown poll interval
- `--reconnect-min-delay-ms <MS>` - reconnect delay floor
- `--reconnect-backoff-max-power <N>` - reconnect backoff exponent cap
- `--worker-idle-sleep-ms <MS>` - worker sleep while paused
- `--worker-recv-timeout-ms <MS>` - worker receive timeout
- `--worker-max-slice-ms <MS>` - max worker slice before yielding
- `--worker-slice-check-interval <N>` - loop interval for slice checks
- `--worker-active-poll-interval <N>` - loop interval for active-state checks
- `--worker-stats-flush-threshold <N>` - hash threshold for stats flush
- `--worker-stats-flush-interval-ms <MS>` - periodic stats flush interval

Rule examples:

- `--gpu-cpu-verify ox8=on,hoohash=on,autolykosv2=off`
- `--gpu-opencl-mad-enable hoohash=off`
- `--gpu-opencl-native-math-enable hoohash=off`
- `--gpu-opencl-fp-contract-disable hoohash=on`
- `--gpu-opencl-accuracy-boost hoohash=on`
- `--gpu-cuda-strict-math-enable hoohash=on`
- `--gpu-strict-kernel-verify hoohash=on`
- `--gpu-strict-job ox8=off,hoohash=off,autolykosv2=on`
- `--gpu-recent-job-max-ids hoohash=640`
- `--gpu-recent-job-max-age-ms hoohash=1000`

### Backend Selection

- `--gpu-backend <auto|cuda|opencl>` - preferred GPU backend
- `--cuda` / `--no-cuda` - enable CUDA preference or disable CUDA
- `--cuda-experimental` - enable experimental CUDA hash path at runtime (testing only; not performance-optimized yet)
- `--opencl` / `--no-opencl` - enable OpenCL preference or disable OpenCL

### OC Command Runner

- `--oc` / `--no-oc` - enable or disable OC command phase
- `--oc-on-start` / `--no-oc-on-start` - apply OC commands on startup
- `--oc-fail-on-error` / `--oc-ignore-errors` - abort or continue on OC errors
- `--oc-dry-run` / `--no-oc-dry-run` - print only or execute commands
- `--oc-timeout-ms <MS>` - timeout per OC command
- `--oc-cmd "<CMD>"` - generic OC command template (repeatable)
- `--oc-nvidia-cmd "<CMD>"` - NVIDIA OC command template (repeatable)
- `--oc-amd-cmd "<CMD>"` - AMD OC command template (repeatable)
- `--oc-intel-cmd "<CMD>"` - Intel OC command template (repeatable)

Supported OC placeholders:

- `{id}` - internal runtime device index
- `{device_id}` - physical device index reported by backend
- `{vendor}` - normalized vendor key (`amd`, `nvidia`, `intel`, ...)
- `{vendor_name}` - full vendor string
- `{backend}` - active backend (`cuda` or `opencl`)

### Startup Extras

- `--window-title <TITLE>` - set console window title
- `--startup-cmd "<CMD>"` - run one startup command before mining
- `--startup-timeout-ms <MS>` - timeout for startup command
- `--gpu-sensors` / `--no-gpu-sensors` - enable or disable GPU sensor reads
- `--randomx-hugepages <auto|on|off>` - RandomX huge pages mode (for all RandomX coins, e.g. Monero/Zephyr)
- `--randomx-msr <auto|on|off>` - RandomX MSR tuning mode (best-effort; admin/root needed)

### Algorithm and CPU Feature Switches

- `--ox8-avx2` / `--no-ox8-avx2` - force AVX2 backend on or off (if supported)

### Config, Logging, and Output

- `-c, --config <FILE>` - config file path
- `-v, --verbose` - increase log verbosity (repeatable)
- `--log-file <FILE>` - write logs to file
- `--no-color` - disable colored output

### REST API

- Default bind: `127.0.0.1:48673`
- Hive-compatible stats endpoint uses the same port (`/hiveos/stats` by default).
- `--api-live` / `--api-disabled` - enable or disable REST API
- `--api-bind <ADDR>` - API bind address
- `--api-port <PORT>` - API port
- `--api-token <TOKEN>` - require Bearer token for REST API endpoints
- `--hive-stats-disabled` - disable Hive-compatible endpoint
- `--hive-stats-path <PATH>` - custom Hive endpoint path

### Frontend

- `--frontend-disabled` - disable embedded frontend
- `--frontend-logs-enabled` - force-enable frontend miner log pane
- `--frontend-logs-disabled` - disable frontend miner log pane
- `--frontend-bind <ADDR>` - frontend bind address
- `--frontend-port <PORT>` - frontend port
- `--frontend-password-enabled` - require frontend password
- `--frontend-password <PASS>` - set frontend password
- `--frontend-rate-limit-per-minute <N>` - request limit per IP

### Benchmark Telemetry

- `--bench-report` / `--no-bench-report` - enable or disable benchmark telemetry uploads
- `--bench-report-interval-sec <SECONDS>` - upload interval
- `--bench-report-id-file <PATH>` - reporter id persistence file
- `--bench-report-api-key <TOKEN>` - optional `X-Api-Key` header for collector auth
- `--bench-insights` / `--no-bench-insights` - enable or disable device-vs-network comparison insights

Notes:

- Upload failures are ignored by design and never stop mining.
- If id-file creation fails, a runtime-only reporter id is used automatically.
- Collector URL is embedded in the miner binary and not exposed via config/CLI.
- The miner accepts both secure and insecure transport fallback for this optional cloud feature.

### Utility Flags

- `-h, --help` - show help
- `-V, --version` - show version

## API Endpoints

When API is enabled:

- `GET /api/v1/health`
- `GET /api/v1/stats`
- `GET /api/v1/telemetry`
- `GET /api/v1/system`
- `GET /api/v1/devices`
- `GET /api/v1/hive`
- `GET /hiveos/stats` (or custom `hive_stats_path`)

Full developer API reference:

- [API.md](API.md)

## Config File

Use the shipped config as your baseline:

- [configs/default.toml](configs/default.toml)

Benchmark telemetry in config:

- Section: `[benchmark_telemetry]`
- Default: enabled
- Intended use: optional benchmark/performance analytics only

Generate a fresh config from current defaults:

```bash
cryptis-miner config generate --output myconfig.toml
```

Validate a config:

```bash
cryptis-miner config validate --file myconfig.toml
```

#### Cryptis Miner does not allow mining on rplant.xyz (including subdomains/server IPs) due to ethical concerns regarding the operators. The software will terminate immediately upon startup; mining on the Rplant pool is not possible, but mining on all other pools is.

## Support
Support in Cryptix Network Discord (Cryptis Miner Channel):
https://discord.cryptix-network.org/

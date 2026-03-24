# Batch Starter Scripts (Windows)

This folder contains ready-to-use `.bat` templates for common mining setups.

## Folder Structure

- `batch/` -> curated starter scripts (recommended first choice)
- `batch/archive/` -> extended matrix variants for niche combinations

## Script Types

- `start-cpu-*` -> CPU-only mining
- `start-gpu-*` -> GPU-only mining
- `start-hybrid-*` -> CPU + GPU mixed mining
- `start-dual-*` -> dual GPU lanes (core + memory, OpenCL lane mode)
- `start-triple-*` -> CPU + dual GPU lanes
- `start-hoohash-opencl.bat` -> HooHash precision-focused OpenCL profile
- `start-hoohash-cuda.bat` -> HooHash precision-focused CUDA profile
- `developer-start.bat` -> advanced all-in-one launcher with many runtime toggles

## Important Combination Coverage

CPU starters in `batch/`:

- `start-cpu-cryptix-ox8.bat`
- `start-cpu-hoosat-hoohash.bat`
- `start-cpu-pepepow-hoohash.bat`
- `start-cpu-monero-randomx.bat`
- `start-cpu-zephyr-randomx.bat`
- `start-cpu-ergo-autolykosv2.bat`
- `start-cpu-unknown-ox8.bat`
- `start-cpu-unknown-hoohash.bat`
- `start-cpu-unknown-randomx.bat`
- `start-cpu-unknown-autolykosv2.bat`

GPU starters in `batch/`:

- `start-gpu-cryptix-ox8.bat`
- `start-gpu-hoosat-hoohash.bat`
- `start-gpu-pepepow-hoohash.bat`
- `start-gpu-ergo-autolykosv2.bat`
- `start-gpu-unknown-ox8.bat`
- `start-gpu-unknown-hoohash.bat`
- `start-gpu-unknown-autolykosv2.bat`

Additional hybrid/extended combinations are available in `batch/` and `batch/archive/`.

## Common Runtime Toggles

Most GPU/Hybrid scripts expose:

- `GPU_BACKEND=auto|cuda|opencl`
- `CUDA_EXPERIMENTAL=1` to append `--cuda-experimental`
- `NO_CUDA=1` and/or `NO_OPENCL=1` to force-disable a backend
- `GPU_DEVICES`, `CUDA_DEVICES`, `OPENCL_DEVICES` for routing
- `GPU_AUTOTUNE_ROUNDS` for startup tuning speed/quality
- `GPU_INTENSITY` for load tuning

Dual/Triple scripts also expose:

- `GPU_CORE_INTENSITY`
- `GPU_MEMORY_INTENSITY`
- lane-specific pool/wallet/failover variables

## Naming Convention

- Hybrid:
  - `start-hybrid-<cpu-coin>-<cpu-hash>__<gpu-coin>-<gpu-hash>.bat`
- Dual:
  - `start-dual-<gpu-core-coin>-<gpu-core-hash>__<gpu-memory-coin>-<gpu-memory-hash>.bat`
- Triple:
  - `start-triple-<cpu-coin>-<cpu-hash>__<gpu-core-coin>-<gpu-core-hash>__<gpu-memory-coin>-<gpu-memory-hash>.bat`

## Notes

- `start-gpu-unknown-randomx-opencl-compat.bat` is a legacy filename and currently starts `unknown + hoohash` with a compatibility profile.
- Archive scripts are runnable directly and resolve the miner binary from the repository root.

# Cryptis Miner - Quick Install (Windows, Linux, HiveOS)

This guide is intentionally short and practical.

> Important: OpenCL is the recommended GPU backend in the current public build.  
> CUDA can be enabled with `--cuda --cuda-experimental` for testing, but CUDA hashing is not performance-optimized yet.

## Windows (prebuilt binaries)

1. Download the latest Windows binary from GitHub Releases:  
   https://github.com/cryptix-network/cryptis-miner/releases
2. Extract the ZIP to a folder (for example `C:\cryptis-miner`).
3. Install GPU runtime dependencies:
   - CUDA 12.4 (optional, for experimental CUDA testing):  
     https://developer.nvidia.com/cuda-12-4-0-download-archive
   - OpenCL runtime (required now): install latest GPU driver
     - NVIDIA: https://www.nvidia.com/Download/index.aspx
     - AMD: https://www.amd.com/en/support/download/drivers.html
     - Intel: https://www.intel.com/content/www/us/en/support/detect.html
4. Reboot after driver/runtime install.

Start example:

```powershell
.\cryptis-miner.exe mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01
```

Windows GPU-only example (`--no-cpu`):

```powershell
.\cryptis-miner.exe mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-cpu --gpu-backend opencl
```

## Linux install

Download and install the Linux binary (replace URL with your release asset URL):

```bash
mkdir -p ~/cryptis-miner && cd ~/cryptis-miner
curl -L "<LINUX_RELEASE_ASSET_URL>" -o cryptis-miner
chmod +x cryptis-miner
./cryptis-miner --help
```

Install OpenCL loader tools:

```bash
sudo apt update
sudo apt install -y ocl-icd-libopencl1 clinfo
clinfo | head -n 20
```

Note: OpenCL also needs a working vendor GPU driver (NVIDIA/AMD/Intel).

Manual runtime install (if OpenCL/CUDA is missing):

```bash
# 1) OpenCL loader + diagnostics
sudo apt update
sudo apt install -y ocl-icd-libopencl1 opencl-headers clinfo

# 2) NVIDIA driver (includes NVIDIA OpenCL runtime)
sudo ubuntu-drivers autoinstall
sudo reboot

# 3) CUDA 12.4 toolkit (optional for experimental CUDA testing)
# Ubuntu 22.04 example:
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-4
nvcc --version
```

If you use Ubuntu 20.04, replace `ubuntu2204` with `ubuntu2004` in the CUDA keyring URL.

Start example:

```bash
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01
```

## HiveOS install (Custom Miner)

Install binary on rig (replace URL with your Linux release asset URL):

```bash
sudo mkdir -p /hive/miners/custom/cryptis-miner
cd /hive/miners/custom/cryptis-miner
sudo curl -L "<LINUX_RELEASE_ASSET_URL>" -o cryptis-miner
sudo chmod +x cryptis-miner
```

OpenCL on HiveOS: normally included with GPU drivers.  
If OpenCL is missing, update/reinstall your GPU driver package in HiveOS, then verify with `clinfo`.

Manual HiveOS commands (if runtime is broken):

```bash
# Quick checks
clinfo | head -n 40
nvidia-smi

# NVIDIA rigs: reinstall/update driver (OpenCL comes with driver)
nvidia-driver-update --list
nvidia-driver-update
reboot

# Optional CUDA 12.4 toolkit for experimental CUDA testing
# (usually not needed on HiveOS for current build)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-4
nvcc --version
```

### HiveOS Custom Flight Sheet (quick idea)

Use a Custom miner entry and pass config in `CUSTOM_URL` style. Example:

```text
POOL:stratum+tcp://POOL:PORT,TEMPLATE:YOUR_WALLET.rig01,PASS:x,COIN:cryptix,HASH:ox8,GPU_BACKEND:opencl,NO_CPU:1
```

RandomX example:

```text
POOL:stratum+tcp://RANDOMX_POOL:PORT,TEMPLATE:YOUR_MONERO_WALLET.rig01,PASS:x,COIN:monero,HASH:randomx,NO_GPU:1
```

Autolykos v2 CPU-only example:

```text
POOL:stratum+tcp://ERGO_POOL:PORT,TEMPLATE:YOUR_ERGO_WALLET.rig01,PASS:x,COIN:ergo,HASH:autolykosv2,NO_GPU:1
```

Hybrid mixed-target example (CPU RandomX + GPU ox8 with separate pools):

```text
POOL:stratum+tcp://RANDOMX_POOL:PORT,TEMPLATE:CPU_WALLET.rig01,PASS:x,COIN:monero,HASH:randomx,GPU_COIN:unknown,GPU_HASH:ox8,CPU_POOL:stratum+tcp://RANDOMX_POOL:PORT,GPU_POOL:stratum+tcp://OX8_POOL:PORT,GPU_WALLET:GPU_WALLET
```

HooHash GPU example (safe defaults, OpenCL):

```text
POOL:stratum+tcp://HOOHASH_POOL:PORT,TEMPLATE:YOUR_WALLET.rig01,PASS:x,COIN:hoosat,HASH:hoohash,GPU_BACKEND:opencl,NO_CPU:1,GPU_CPU_VERIFY:hoohash=on,GPU_OPENCL_NATIVE_MATH_ENABLE:hoohash=off,GPU_OPENCL_ACCURACY_BOOST:hoohash=off
```

HiveOS mode flags:
- GPU-only: `NO_CPU:1`
- CPU-only: `NO_GPU:1`
- Hybrid (CPU+GPU): remove both flags

Useful keys:
- `POOL`, `TEMPLATE`, `PASS`
- `COIN`, `HASH`
- `CPU_COIN`, `CPU_HASH`, `GPU_COIN`, `GPU_HASH`
- `CPU_POOL`, `CPU_FAILOVER_POOLS`, `CPU_USER`, `CPU_PASSWORD`, `CPU_WALLET`
- `GPU_POOL`, `GPU_FAILOVER_POOLS`, `GPU_USER`, `GPU_PASSWORD`, `GPU_WALLET`
- `NO_CPU`, `NO_GPU`
- `GPU_BACKEND` (`opencl` recommended for current build)
- `GPU_DEVICES` (for example `0,1`)
- `GPU_CPU_VERIFY` (for example `hoohash=on`)
- `GPU_OPENCL_MAD_ENABLE` (for example `hoohash=off`)
- `GPU_OPENCL_NATIVE_MATH_ENABLE` (for example `hoohash=off`)
- `GPU_OPENCL_ACCURACY_BOOST` (for example `hoohash=on`; hoohash-only and requires `GPU_CPU_VERIFY` for hoohash)
- `GPU_STRICT_JOB`, `GPU_RECENT_JOB_MAX_IDS`, `GPU_RECENT_JOB_MAX_AGE_MS`
- `HYBRID_CPU_RESERVE_MIN_CORES` (reserved CPU cores for hybrid when GPU count is small)
- `HYBRID_CPU_RESERVE_MAX_CORES` (reserved CPU cores for hybrid when GPU count is large)
- `HYBRID_CPU_RESERVE_GPU_THRESHOLD` (GPU-count switch threshold for min/max reserve)
- `CPU_ONLY_RESERVE_SYSTEM_CORE` (`1/0` toggle for CPU-only system-core reservation)
- `CPU_ONLY_RESERVED_CORES` (reserved CPU cores in CPU-only mode, default `1`)
- `FRONTEND_LOGS_DISABLED` (`1` disables frontend log pane, default `0`)
- `AUTOLYKOS_BLOCK_SIZE` (Autolykos-only GPU block size; `>=64`, divisible by `8`)

Supported coin/hash pairs in HiveOS wrapper:
- `cryptix + ox8`
- `hoosat + hoohash`
- `pepepow + hoohash`
- `monero + randomx`
- `zephyr + randomx`
- `ergo + autolykosv2`
- `unknown + ox8`
- `unknown + hoohash`
- `unknown + randomx`
- `unknown + autolykosv2`

## Quick start arguments (most important)

- `--pool` pool URL
- `--wallet` wallet address
- `--worker` worker name
- `--coin` one of `cryptix`, `hoosat`, `pepepow`, `monero`, `zephyr`, `ergo`, `unknown`
- `--hash` one of `ox8`, `hoohash`, `randomx`, `autolykosv2`
- `--cpu-coin`, `--cpu-hash`, `--gpu-coin`, `--gpu-hash`
- `--cpu-pool`, `--cpu-failover-pools`, `--gpu-pool`, `--gpu-failover-pools`
- `--threads` CPU threads
- `--no-cpu` GPU-only
- `--no-gpu` CPU-only
- `--gpu-devices` select GPU indexes (example `0,1`)
- `--gpu-backend opencl` force OpenCL backend
- `--gpu-cpu-verify hoohash=on`
- `--gpu-opencl-native-math-enable hoohash=off`
- `--gpu-opencl-accuracy-boost hoohash=off`
- `--cuda --cuda-experimental` enable experimental CUDA test path (not performance-optimized yet)

Examples:

```bash
# GPU only (recommended with current build)
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-cpu --gpu-backend opencl

# Experimental CUDA test run (functional validation only)
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-cpu --cuda --cuda-experimental

# CPU only
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-gpu --threads 6

# CPU RandomX
./cryptis-miner mine --coin monero --hash randomx --pool stratum+tcp://RANDOMX_POOL:PORT --wallet YOUR_MONERO_WALLET --worker rig01 --no-gpu

# CPU Autolykos v2 (reference verifier path)
./cryptis-miner mine --coin ergo --hash autolykosv2 --pool stratum+tcp://ERGO_POOL:PORT --wallet YOUR_ERGO_WALLET --worker rig01 --no-gpu

# Hybrid mixed target (CPU RandomX + GPU ox8)
./cryptis-miner mine --coin monero --hash randomx --pool stratum+tcp://RANDOMX_POOL:PORT --wallet CPU_WALLET --worker rig01 --cpu-pool stratum+tcp://RANDOMX_POOL:PORT --gpu-pool stratum+tcp://OX8_POOL:PORT --gpu-wallet GPU_WALLET --gpu-coin unknown --gpu-hash ox8
```

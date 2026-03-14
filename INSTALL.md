# Cryptis Miner - Quick Install (Windows, Linux, HiveOS)

This guide is intentionally short and practical.

> Important: GPU mining in the current public build uses OpenCL.  
> CUDA support (target: CUDA 12.4) is planned, but CUDA hashing is not active yet in this build.

## Windows (prebuilt binaries)

1. Download the latest Windows binary from GitHub Releases:  
   https://github.com/cryptix-network/cryptis-miner/releases
2. Extract the ZIP to a folder (for example `C:\cryptis-miner`).
3. Install GPU runtime dependencies:
   - CUDA 12.4 (for future CUDA-enabled builds):  
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

# 3) CUDA 12.4 toolkit (optional for future CUDA builds)
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

# Optional CUDA 12.4 toolkit for future CUDA-enabled miner builds
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

HiveOS mode flags:
- GPU-only: `NO_CPU:1`
- CPU-only: `NO_GPU:1`
- Hybrid (CPU+GPU): remove both flags

Useful keys:
- `POOL`, `TEMPLATE`, `PASS`
- `COIN`, `HASH`
- `NO_CPU`, `NO_GPU`
- `GPU_BACKEND` (`opencl` recommended for current build)
- `GPU_DEVICES` (for example `0,1`)

## Quick start arguments (most important)

- `--pool` pool URL
- `--wallet` wallet address
- `--worker` worker name
- `--coin` currently `cryptix`
- `--hash` currently `ox8`
- `--threads` CPU threads
- `--no-cpu` GPU-only
- `--no-gpu` CPU-only
- `--gpu-devices` select GPU indexes (example `0,1`)
- `--gpu-backend opencl` force OpenCL backend

Examples:

```bash
# GPU only (recommended with current build)
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-cpu --gpu-backend opencl

# CPU only
./cryptis-miner mine --coin cryptix --hash ox8 --pool stratum+tcp://POOL:PORT --wallet YOUR_WALLET --worker rig01 --no-gpu --threads 6
```

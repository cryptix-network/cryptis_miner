@echo off
setlocal
cd /d "%~dp0"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"

set "MINER_EXE=%ROOT_DIR%\cryptis-miner.exe"
if not exist "%MINER_EXE%" set "MINER_EXE=%ROOT_DIR%\target\release\cryptis-miner.exe"
if not exist "%MINER_EXE%" set "MINER_EXE=%SCRIPT_DIR%cryptis-miner.exe"
if not exist "%MINER_EXE%" set "MINER_EXE=%SCRIPT_DIR%target\release\cryptis-miner.exe"
if not exist "%MINER_EXE%" (
    echo [ERROR] Could not find cryptis-miner.exe
    echo [ERROR] Looked in:
    echo [ERROR]   "%ROOT_DIR%\cryptis-miner.exe"
    echo [ERROR]   "%ROOT_DIR%\target\release\cryptis-miner.exe"
    echo [ERROR]   "%SCRIPT_DIR%cryptis-miner.exe"
    echo [ERROR]   "%SCRIPT_DIR%target\release\cryptis-miner.exe"
    pause
    exit /b 1
)
REM CPU+GPU hybrid: CPU monero+randomx and GPU cryptix+ox8

set WORKER_NAME=rig01
set THREADS=

set GPU_DEVICES=
set CUDA_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=auto
set NO_CUDA=0
set NO_OPENCL=0

set CPU_POOL_URL=stratum+tcp://randomx-cpu-pool.example.com:3333
set CPU_FAILOVER_URLS=
set CPU_WALLET=YOUR_MONERO_WALLET
set CPU_USER=
set CPU_PASSWORD=x

set GPU_POOL_URL=stratum+tcp://ox8-gpu-pool.example.com:4444
set GPU_FAILOVER_URLS=
set GPU_WALLET=cryptix:YOUR_CRYPTIX_WALLET
set GPU_USER=
set GPU_PASSWORD=x
set RANDOMX_HUGEPAGES=off
set RANDOMX_MSR=off
set EXTRA_ARGS=
if not "%GPU_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-devices %GPU_DEVICES%
)
if not "%CUDA_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda-devices %CUDA_DEVICES%
)
if not "%OPENCL_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --opencl-devices %OPENCL_DEVICES%
)
if not "%GPU_BACKEND%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-backend %GPU_BACKEND%
)
if "%NO_CUDA%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda
)
if "%NO_OPENCL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-opencl
)
if not "%CPU_FAILOVER_URLS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cpu-failover-pools %CPU_FAILOVER_URLS%
)
if not "%GPU_FAILOVER_URLS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-failover-pools %GPU_FAILOVER_URLS%
)
if not "%CPU_USER%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cpu-user %CPU_USER%
)
if not "%GPU_USER%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-user %GPU_USER%
)

if "%THREADS%"=="" (
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin monero --hash randomx --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-pool %GPU_POOL_URL% --gpu-wallet %GPU_WALLET% --gpu-password %GPU_PASSWORD% --gpu-coin cryptix --gpu-hash ox8 --randomx-hugepages %RANDOMX_HUGEPAGES% --randomx-msr %RANDOMX_MSR% %EXTRA_ARGS%
) else (
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin monero --hash randomx --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-pool %GPU_POOL_URL% --gpu-wallet %GPU_WALLET% --gpu-password %GPU_PASSWORD% --gpu-coin cryptix --gpu-hash ox8 --threads %THREADS% --randomx-hugepages %RANDOMX_HUGEPAGES% --randomx-msr %RANDOMX_MSR% %EXTRA_ARGS%
)

pause


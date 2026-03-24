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
REM Triple mode: CPU monero+randomx + GPU core unknown+ox8 + GPU memory unknown+autolykosv2 (OpenCL)

set WORKER_NAME=rig01
set THREADS=

set GPU_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=opencl
set NO_CUDA=1

set GPU_AUTOTUNE_ROUNDS=
set GPU_CORE_INTENSITY=0.55
set GPU_MEMORY_INTENSITY=0.45

set CPU_POOL_URL=stratum+tcp://randomx-cpu-pool.example.com:3333
set CPU_FAILOVER_URLS=
set CPU_WALLET=YOUR_RANDOMX_WALLET_OR_LOGIN
set CPU_USER=
set CPU_PASSWORD=x

set GPU_CORE_POOL_URL=stratum+tcp://ox8-core-pool.example.com:4444
set GPU_CORE_FAILOVER_URLS=
set GPU_CORE_WALLET=YOUR_OX8_WALLET_OR_LOGIN
set GPU_CORE_USER=
set GPU_CORE_PASSWORD=x

set GPU_MEMORY_POOL_URL=stratum+tcp://autolykos-memory-pool.example.com:5555
set GPU_MEMORY_FAILOVER_URLS=
set GPU_MEMORY_WALLET=YOUR_AUTOLYKOS_WALLET_OR_LOGIN
set GPU_MEMORY_USER=
set GPU_MEMORY_PASSWORD=x

set EXTRA_ARGS=
if not "%GPU_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-devices %GPU_DEVICES%
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
if not "%GPU_AUTOTUNE_ROUNDS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-autotune-rounds %GPU_AUTOTUNE_ROUNDS%
)
if not "%CPU_FAILOVER_URLS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cpu-failover-pools %CPU_FAILOVER_URLS%
)
if not "%GPU_CORE_FAILOVER_URLS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-core-failover-pools %GPU_CORE_FAILOVER_URLS%
)
if not "%GPU_MEMORY_FAILOVER_URLS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-memory-failover-pools %GPU_MEMORY_FAILOVER_URLS%
)
if not "%CPU_USER%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cpu-user %CPU_USER%
)
if not "%GPU_CORE_USER%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-core-user %GPU_CORE_USER%
)
if not "%GPU_MEMORY_USER%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-memory-user %GPU_MEMORY_USER%
)

if "%THREADS%"=="" (
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin monero --hash randomx --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-coin unknown --gpu-hash ox8 --gpu-core-coin unknown --gpu-core-hash ox8 --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool %GPU_CORE_POOL_URL% --gpu-core-wallet %GPU_CORE_WALLET% --gpu-core-password %GPU_CORE_PASSWORD% --gpu-memory-pool %GPU_MEMORY_POOL_URL% --gpu-memory-wallet %GPU_MEMORY_WALLET% --gpu-memory-password %GPU_MEMORY_PASSWORD% --gpu-core-intensity %GPU_CORE_INTENSITY% --gpu-memory-intensity %GPU_MEMORY_INTENSITY% %EXTRA_ARGS%
) else (
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin monero --hash randomx --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-coin unknown --gpu-hash ox8 --gpu-core-coin unknown --gpu-core-hash ox8 --gpu-memory-coin unknown --gpu-memory-hash autolykosv2 --gpu-core-pool %GPU_CORE_POOL_URL% --gpu-core-wallet %GPU_CORE_WALLET% --gpu-core-password %GPU_CORE_PASSWORD% --gpu-memory-pool %GPU_MEMORY_POOL_URL% --gpu-memory-wallet %GPU_MEMORY_WALLET% --gpu-memory-password %GPU_MEMORY_PASSWORD% --gpu-core-intensity %GPU_CORE_INTENSITY% --gpu-memory-intensity %GPU_MEMORY_INTENSITY% --threads %THREADS% %EXTRA_ARGS%
)

pause

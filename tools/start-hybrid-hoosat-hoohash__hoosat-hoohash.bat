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
REM CPU+GPU hybrid: CPU hoosat+hoohash and GPU hoosat+hoohash

set WORKER_NAME=rig01
set THREADS=

set GPU_DEVICES=
set CUDA_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=opencl
set GPU_CPU_VERIFY=hoohash=on
set GPU_OPENCL_MAD_ENABLE=hoohash=off
set GPU_OPENCL_NATIVE_MATH_ENABLE=hoohash=off
set GPU_OPENCL_ACCURACY_BOOST=hoohash=off
set NO_CUDA=1
set NO_OPENCL=0
REM Quick GPU options (set as needed)
REM   CUDA experimental: set CUDA_EXPERIMENTAL=1
REM   Faster autotune:  set GPU_AUTOTUNE_ROUNDS=1
REM   GPU intensity:    set GPU_INTENSITY=0.95
set CUDA_EXPERIMENTAL=0
set GPU_INTENSITY=
set GPU_AUTOTUNE_ROUNDS=
set GPU_CUDA_ACCURACY_BOOST=hoohash=off
REM   HooHash accuracy (CUDA):  set GPU_CUDA_ACCURACY_BOOST=hoohash=on
REM   HooHash accuracy (OpenCL): set GPU_OPENCL_ACCURACY_BOOST=hoohash=on

set CPU_POOL_URL=stratum+tcp://hoohash-cpu-pool.example.com:45012
set CPU_FAILOVER_URLS=
set CPU_WALLET=hoosat:YOUR_HOOSAT_WALLET
set CPU_USER=
set CPU_PASSWORD=x

set GPU_POOL_URL=stratum+tcp://hoohash-gpu-pool.example.com:45012
set GPU_FAILOVER_URLS=
set GPU_WALLET=hoosat:YOUR_HOOSAT_WALLET
set GPU_USER=
set GPU_PASSWORD=x

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
if not "%GPU_CPU_VERIFY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cpu-verify %GPU_CPU_VERIFY%
)
if not "%GPU_OPENCL_MAD_ENABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-mad-enable %GPU_OPENCL_MAD_ENABLE%
)
if not "%GPU_OPENCL_NATIVE_MATH_ENABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-native-math-enable %GPU_OPENCL_NATIVE_MATH_ENABLE%
)
if not "%GPU_OPENCL_ACCURACY_BOOST%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-accuracy-boost %GPU_OPENCL_ACCURACY_BOOST%
)
if "%NO_CUDA%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda
)
if "%NO_OPENCL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-opencl
)
if not "%GPU_CUDA_ACCURACY_BOOST%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cuda-accuracy-boost %GPU_CUDA_ACCURACY_BOOST%
)
if "%CUDA_EXPERIMENTAL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda-experimental
)
if not "%GPU_INTENSITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-intensity %GPU_INTENSITY%
)
if not "%GPU_AUTOTUNE_ROUNDS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-autotune-rounds %GPU_AUTOTUNE_ROUNDS%
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
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin hoosat --hash hoohash --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-pool %GPU_POOL_URL% --gpu-wallet %GPU_WALLET% --gpu-password %GPU_PASSWORD% --gpu-coin hoosat --gpu-hash hoohash %EXTRA_ARGS%
) else (
    "%MINER_EXE%" --pool %CPU_POOL_URL% --wallet %CPU_WALLET% --worker %WORKER_NAME% --password %CPU_PASSWORD% --coin hoosat --hash hoohash --cpu-pool %CPU_POOL_URL% --cpu-wallet %CPU_WALLET% --cpu-password %CPU_PASSWORD% --gpu-pool %GPU_POOL_URL% --gpu-wallet %GPU_WALLET% --gpu-password %GPU_PASSWORD% --gpu-coin hoosat --gpu-hash hoohash --threads %THREADS% %EXTRA_ARGS%
)

pause




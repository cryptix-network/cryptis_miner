@echo off
setlocal
cd /d "%~dp0"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"

set "MINER_EXE=%ROOT_DIR%\target\release\cryptis-miner.exe"
if not exist "%MINER_EXE%" set "MINER_EXE=%ROOT_DIR%\cryptis-miner.exe"
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

REM HooHash CUDA profile (max precision/parity focus)
REM Note: CUDA HooHash path requires CUDA experimental mode in this build.
REM Tradeoff: strict verification can reject unstable driver/device FP behavior.

set POOL_URL=stratum+tcp://hoohash-gpu-pool.example.com:45012
set WALLET=hoosat:YOUR_HOOSAT_WALLET
set WORKER_NAME=rig01
set POOL_PASSWORD=x
set COIN=hoosat
set HASH=hoohash

set GPU_DEVICES=
set CUDA_DEVICES=
set GPU_BACKEND=cuda
set NO_CPU=1
set NO_CUDA=0
set NO_OPENCL=1
set CUDA_EXPERIMENTAL=1

set GPU_CPU_VERIFY=hoohash=off
set GPU_CUDA_STRICT_MATH_ENABLE=hoohash=on
set GPU_STRICT_KERNEL_VERIFY=hoohash=on
set GPU_CUDA_ACCURACY_BOOST=hoohash=off

REM Optional tuning
set GPU_INTENSITY=
set GPU_AUTOTUNE_ROUNDS=

set EXTRA_ARGS=
if not "%GPU_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-devices %GPU_DEVICES%
)
if not "%CUDA_DEVICES%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda-devices %CUDA_DEVICES%
)
if not "%GPU_BACKEND%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-backend %GPU_BACKEND%
)
if not "%GPU_CPU_VERIFY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cpu-verify %GPU_CPU_VERIFY%
)
if not "%GPU_CUDA_STRICT_MATH_ENABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cuda-strict-math-enable %GPU_CUDA_STRICT_MATH_ENABLE%
)
if not "%GPU_STRICT_KERNEL_VERIFY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-strict-kernel-verify %GPU_STRICT_KERNEL_VERIFY%
)
if not "%GPU_CUDA_ACCURACY_BOOST%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cuda-accuracy-boost %GPU_CUDA_ACCURACY_BOOST%
)
if "%NO_CUDA%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda
)
if "%NO_OPENCL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-opencl
)
if "%NO_CPU%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cpu
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

echo [INFO] Using miner binary: "%MINER_EXE%"
echo [INFO] HOOHASH CUDA policy: cpu_verify=%GPU_CPU_VERIFY%, strict_kernel_verify=%GPU_STRICT_KERNEL_VERIFY%, cuda_accuracy_boost=%GPU_CUDA_ACCURACY_BOOST%
"%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin %COIN% --hash %HASH% %EXTRA_ARGS%

pause

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

REM HooHash OpenCL profile (max precision/parity focus)
REM Tradeoff: strict verification can reject unstable driver/device FP behavior.

set POOL_URL=stratum+tcp://hoohash-gpu-pool.example.com:45012
set WALLET=hoosat:YOUR_HOOSAT_WALLET
set WORKER_NAME=rig01
set POOL_PASSWORD=x
set COIN=hoosat
set HASH=hoohash

set GPU_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=opencl
set NO_CPU=1
set NO_CUDA=1
set NO_OPENCL=0

set GPU_CPU_VERIFY=hoohash=off
set GPU_OPENCL_MAD_ENABLE=hoohash=off
set GPU_OPENCL_NATIVE_MATH_ENABLE=hoohash=off
set GPU_OPENCL_FP_CONTRACT_DISABLE=hoohash=on
set GPU_STRICT_KERNEL_VERIFY=hoohash=on
set GPU_OPENCL_ACCURACY_BOOST=hoohash=off

REM Optional tuning
set GPU_INTENSITY=
set GPU_AUTOTUNE_ROUNDS=

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
if not "%GPU_CPU_VERIFY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-cpu-verify %GPU_CPU_VERIFY%
)
if not "%GPU_OPENCL_MAD_ENABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-mad-enable %GPU_OPENCL_MAD_ENABLE%
)
if not "%GPU_OPENCL_NATIVE_MATH_ENABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-native-math-enable %GPU_OPENCL_NATIVE_MATH_ENABLE%
)
if not "%GPU_OPENCL_FP_CONTRACT_DISABLE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-opencl-fp-contract-disable %GPU_OPENCL_FP_CONTRACT_DISABLE%
)
if not "%GPU_STRICT_KERNEL_VERIFY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-strict-kernel-verify %GPU_STRICT_KERNEL_VERIFY%
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
if "%NO_CPU%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cpu
)
if not "%GPU_INTENSITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-intensity %GPU_INTENSITY%
)
if not "%GPU_AUTOTUNE_ROUNDS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-autotune-rounds %GPU_AUTOTUNE_ROUNDS%
)

echo [INFO] Using miner binary: "%MINER_EXE%"
echo [INFO] HOOHASH OpenCL policy: cpu_verify=%GPU_CPU_VERIFY%, strict_kernel_verify=%GPU_STRICT_KERNEL_VERIFY%, opencl_accuracy_boost=%GPU_OPENCL_ACCURACY_BOOST%
"%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin %COIN% --hash %HASH% %EXTRA_ARGS%

pause

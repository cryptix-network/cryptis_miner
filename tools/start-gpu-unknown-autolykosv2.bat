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
REM GPU-only: unknown + autolykosv2

set POOL_URL=stratum+tcp://ergo-gpu-pool.example.com:4444
set WALLET=YOUR_POOL_LOGIN_OR_WALLET
set WORKER_NAME=rig01
set POOL_PASSWORD=x

set GPU_DEVICES=
set CUDA_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=auto
set NO_CUDA=0
set NO_OPENCL=0
REM Quick GPU options (set as needed)
REM   CUDA experimental: set CUDA_EXPERIMENTAL=1
REM   Faster autotune:  set GPU_AUTOTUNE_ROUNDS=1
REM   GPU intensity:    set GPU_INTENSITY=0.95
set CUDA_EXPERIMENTAL=0
set GPU_INTENSITY=
set GPU_AUTOTUNE_ROUNDS=
set GPU_CUDA_ACCURACY_BOOST=

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

"%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin unknown --hash autolykosv2 --no-cpu %EXTRA_ARGS%

pause




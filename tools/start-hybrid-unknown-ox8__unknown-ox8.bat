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
REM CPU+GPU hybrid: CPU unknown+ox8 and GPU unknown+ox8

set POOL_URL=stratum+tcp://ox8-cpu-pool.example.com:3333
set WALLET=YOUR_UNKNOWN_OR_GENERIC_WALLET
set WORKER_NAME=rig01
set POOL_PASSWORD=x
set THREADS=

set GPU_DEVICES=
set CUDA_DEVICES=
set OPENCL_DEVICES=
set GPU_BACKEND=auto
set NO_CUDA=0
set NO_OPENCL=0

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
set EXTRA_ARGS=%EXTRA_ARGS% --gpu-coin unknown --gpu-hash ox8

if "%THREADS%"=="" (
    "%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin unknown --hash ox8 %EXTRA_ARGS%
) else (
    "%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin unknown --hash ox8 --threads %THREADS% %EXTRA_ARGS%
)

pause


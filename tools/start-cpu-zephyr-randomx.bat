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
REM CPU-only: zephyr + randomx

set POOL_URL=stratum+tcp://randomx-cpu-pool.example.com:3333
set WALLET=YOUR_ZEPHYR_WALLET
set WORKER_NAME=rig01
set POOL_PASSWORD=x
set THREADS=
set RANDOMX_HUGEPAGES=off
set RANDOMX_MSR=off
if "%THREADS%"=="" (
    "%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin zephyr --hash randomx --no-gpu --randomx-hugepages %RANDOMX_HUGEPAGES% --randomx-msr %RANDOMX_MSR%
) else (
    "%MINER_EXE%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin zephyr --hash randomx --no-gpu --threads %THREADS% --randomx-hugepages %RANDOMX_HUGEPAGES% --randomx-msr %RANDOMX_MSR%
)

pause


@echo off
setlocal
REM Cryptis Miner

REM Required
set POOL_URL=stratum+tcp://stratum.cryptix-network.org:13094
set WALLET=cryptix:qrjefk2r8wp607rmyvxmgjansqcwugjazpu2kk2r7057gltxetdvk8gl9fs0w
set WORKER_NAME=rig01

REM Optional basics
set POOL_PASSWORD=x
set COIN=cryptix
set HASH=ox8
set THREADS=

set BIN=%~dp0cryptix.exe
if not exist "%BIN%" set BIN=%~dp0cryptis-miner.exe

if not exist "%BIN%" (
    echo [ERROR] Binary not found. Expected one of:
    echo   %~dp0cryptix.exe
    echo   %~dp0cryptis-miner.exe
    pause
    exit /b 1
)

if "%THREADS%"=="" (
    "%BIN%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin %COIN% --hash %HASH% --no-cpu
) else (
    "%BIN%" --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --threads %THREADS% --coin %COIN% --hash %HASH% --no-cpu
)

pause

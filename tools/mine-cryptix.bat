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

if "%THREADS%"=="" (
    cryptis-miner.exe --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin %COIN% --hash %HASH% --no-cpu
) else (
    cryptis-miner.exe --pool %POOL_URL% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --threads %THREADS% --coin %COIN% --hash %HASH% --no-cpu
)

pause

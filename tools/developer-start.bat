@echo off
REM Cryptis Miner Start Script

REM Pool URL 
:: set POOL_URL=stratum+tcp://127.0.0.1:13094
:: set POOL_URL=stratum+tcp://stratum.cryptix-network.org:13094

set POOL_URL=stratum+tcp://127.0.0.1:13094

REM Mining wallet address 
set WALLET=cryptix:qrp4feqvf3u0ehge7hpq5agpn8m5p68akh7s6lzjcvhj8p2qt02sxysjztlma

REM Worker/Rig name 
set WORKER_NAME=cryptis

REM Pool password (usually "x" or empty)
set POOL_PASSWORD=x

REM Number of CPU threads to use (leave empty for auto-detect)
set THREADS=6

REM Optional CPU affinity list (comma-separated cores, e.g. 0,2,4,6)
set CPU_AFFINITY=

REM Optional GPU device ids (comma-separated, e.g. 0,1)
set GPU_DEVICES=
REM Optional explicit backend device maps for mixed rigs
set CUDA_DEVICES=
set OPENCL_DEVICES=

REM GPU backend selection: auto, cuda, opencl
set GPU_BACKEND=auto

REM Backend toggles (1=true, 0=false)
REM CUDA_MODE controls CUDA explicitly:
REM   auto = no explicit CUDA flag 
REM   on   = pass --cuda
REM   off  = pass --no-cuda
set CUDA_MODE=auto
REM Required if CUDA rollout toggle is false in source:
REM   1/true/on = pass --cuda-experimental
REM   0/false/off = do not pass
set CUDA_EXPERIMENTAL=0
set NO_CUDA=0
set NO_OPENCL=0
set DISABLE_GPU_AMD=0
set DISABLE_GPU_NVIDIA=0
set DISABLE_GPU_INTEL=0

REM Optional global/cpu/gpu intensity values
set INTENSITY=
set INTENSITY_MIN=
set INTENSITY_MAX=
set CPU_INTENSITY=
set GPU_INTENSITY=

REM Optional mode flags (1=true, 0=false)
set NO_CPU=1
set NO_GPU=0

REM Coin/Hash target
set COIN=cryptix
set HASH=ox8

REM Stratum transport mode: auto, tcp, tls
set STRATUM_TRANSPORT=auto

REM Optional pool reconnect/timeout tuning
set POOL_RETRY_COUNT=
set POOL_RETRY_DELAY_MS=
set POOL_CONNECT_TIMEOUT_MS=
set POOL_TLS_TIMEOUT_MS=
set POOL_REQUEST_TIMEOUT_MS=
set POOL_JOB_CHANNEL_SIZE=

REM Optional mining runtime tuning
set JOB_RECV_TIMEOUT_MS=
set STATS_INTERVAL_MS=
set SHARE_QUEUE_CAPACITY=
set CUDA_BATCH_SIZE=
set CUDA_BLOCK_SIZE=
set CUDA_AUTOTUNE=

REM Optional HTML frontend
set FRONTEND_DISABLED=0
set FRONTEND_BIND=127.0.0.1
set FRONTEND_PORT=8943
set FRONTEND_PASSWORD_ENABLED=0
set FRONTEND_PASSWORD=
set FRONTEND_RATE_LIMIT_PER_MINUTE=

set EXTRA_ARGS=
if not "%CPU_AFFINITY%"=="" (
    set EXTRA_ARGS=--cpu-affinity %CPU_AFFINITY%
)
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
if not "%INTENSITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --intensity %INTENSITY%
)
if not "%INTENSITY_MIN%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --intensity-min %INTENSITY_MIN%
)
if not "%INTENSITY_MAX%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --intensity-max %INTENSITY_MAX%
)
if not "%CPU_INTENSITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cpu-intensity %CPU_INTENSITY%
)
if not "%GPU_INTENSITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --gpu-intensity %GPU_INTENSITY%
)
if not "%POOL_RETRY_COUNT%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-retry-count %POOL_RETRY_COUNT%
)
if not "%POOL_RETRY_DELAY_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-retry-delay-ms %POOL_RETRY_DELAY_MS%
)
if not "%POOL_CONNECT_TIMEOUT_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-connect-timeout-ms %POOL_CONNECT_TIMEOUT_MS%
)
if not "%POOL_TLS_TIMEOUT_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-tls-timeout-ms %POOL_TLS_TIMEOUT_MS%
)
if not "%POOL_REQUEST_TIMEOUT_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-request-timeout-ms %POOL_REQUEST_TIMEOUT_MS%
)
if not "%POOL_JOB_CHANNEL_SIZE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --pool-job-channel-size %POOL_JOB_CHANNEL_SIZE%
)
if not "%JOB_RECV_TIMEOUT_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --job-recv-timeout-ms %JOB_RECV_TIMEOUT_MS%
)
if not "%STATS_INTERVAL_MS%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --stats-interval-ms %STATS_INTERVAL_MS%
)
if not "%SHARE_QUEUE_CAPACITY%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --share-queue-capacity %SHARE_QUEUE_CAPACITY%
)
if not "%CUDA_BATCH_SIZE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda-batch-size %CUDA_BATCH_SIZE%
)
if not "%CUDA_BLOCK_SIZE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda-block-size %CUDA_BLOCK_SIZE%
)
if not "%FRONTEND_BIND%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-bind %FRONTEND_BIND%
)
if not "%FRONTEND_PORT%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-port %FRONTEND_PORT%
)
if not "%FRONTEND_PASSWORD%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-password %FRONTEND_PASSWORD%
)
if not "%FRONTEND_RATE_LIMIT_PER_MINUTE%"=="" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-rate-limit-per-minute %FRONTEND_RATE_LIMIT_PER_MINUTE%
)
if "%FRONTEND_DISABLED%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-disabled
)
if "%FRONTEND_PASSWORD_ENABLED%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --frontend-password-enabled
)
if "%NO_CPU%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-cpu
)
if "%NO_GPU%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-gpu
)
if /I "%CUDA_MODE%"=="on" (
    set EXTRA_ARGS=%EXTRA_ARGS% --cuda
) else (
    if /I "%CUDA_MODE%"=="off" (
        set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda
    ) else (
        if "%NO_CUDA%"=="1" (
            set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda
        )
    )
)
if "%NO_OPENCL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --no-opencl
)
if "%DISABLE_GPU_AMD%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --disable-gpu-amd
)
if "%DISABLE_GPU_NVIDIA%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --disable-gpu-nvidia
)
if "%DISABLE_GPU_INTEL%"=="1" (
    set EXTRA_ARGS=%EXTRA_ARGS% --disable-gpu-intel
)
if not "%CUDA_AUTOTUNE%"=="" (
    if /I "%CUDA_AUTOTUNE%"=="1" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="true" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="yes" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="on" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="0" set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="false" set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="no" set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda-autotune
    if /I "%CUDA_AUTOTUNE%"=="off" set EXTRA_ARGS=%EXTRA_ARGS% --no-cuda-autotune
)
if not "%CUDA_EXPERIMENTAL%"=="" (
    if /I "%CUDA_EXPERIMENTAL%"=="1" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-experimental
    if /I "%CUDA_EXPERIMENTAL%"=="true" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-experimental
    if /I "%CUDA_EXPERIMENTAL%"=="yes" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-experimental
    if /I "%CUDA_EXPERIMENTAL%"=="on" set EXTRA_ARGS=%EXTRA_ARGS% --cuda-experimental
)

if "%THREADS%"=="" (
    target\release\cryptis-miner.exe  --pool %POOL_URL% --stratum-transport %STRATUM_TRANSPORT% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --coin %COIN% --hash %HASH% %EXTRA_ARGS%
) else (
    target\release\cryptis-miner.exe  --pool %POOL_URL% --stratum-transport %STRATUM_TRANSPORT% --wallet %WALLET% --worker %WORKER_NAME% --password %POOL_PASSWORD% --threads %THREADS% --coin %COIN% --hash %HASH% %EXTRA_ARGS%
)

pause

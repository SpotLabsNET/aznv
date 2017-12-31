cd /d %~dp0

setx GPU_FORCE_64BIT_PTR 1
setx GPU_MAX_HEAP_SIZE 100
setx GPU_USE_SYNC_OBJECTS 1
setx GPU_MAX_ALLOC_PERCENT 100
setx GPU_SINGLE_ALLOC_PERCENT 100

rem set "command=& .\multipoolminer.ps1 -wallet 3KAQAwbnCAb2ZbUPVpmCsQYLv5fGj7UVDa -username OllaKolla -workername ok -region usa -currency btc,usd -type nvidia,cpu -poolname miningpoolhub,miningpoolhubcoins,nicehash -algorithm neoscrypt -donate 24 -watchdog -switchingprevention 2"

set "command=& .\multipoolminer.ps1 -wallet 3KAQAwbnCAb2ZbUPVpmCsQYLv5fGj7UVDa -username OllaKolla -workername ok -interval 180 -region usa -currency btc,usd -type cpu -poolname miningpoolhub,miningpoolhubcoins -algorithm CryptoNight -donate 24 -watchdog -switchingprevention 2"

pwsh -noexit -noprofile -executionpolicy bypass -windowstyle maximized -command "%command%"

pause

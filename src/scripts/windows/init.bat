@echo off
rem bash complains if it can't find a /tmp directory:
set maketmp=n
if not exist \tmp set maketmp=y
if %maketmp% == y md \tmp
cmd /c start /min .\bash bash_init %1 %2 %3 %4 %5 %6 %7 %8 %9
if %maketmp% == y rmdir \tmp

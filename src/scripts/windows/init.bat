@echo off
rem bash complains if it can't find a /tmp directory:
set maketmp=n
if not exist \tmp set maketmp=y
if %maketmp% == y md \tmp
%comspec% /c start /min .\bash bash_init %1 %2 %3 %4 %5 %6 %7 %8 %9
rem clean up
del bash.exe cp.exe cygwin1.dll mkdir.exe sed.exe repl_spec
if %maketmp% == y rmdir \tmp

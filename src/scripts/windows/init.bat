@echo off
rem bash complains if it can't find a /tmp directory:
set maketmp=n
if not exist \tmp set maketmp=y
if %maketmp% == y md \tmp
%comspec% /c start /min .\bash bash_init %1 %2 %3 %4 %5 %6 %7 %8 %9
set n=1
:loop
if %n% == 5 goto end
if exist finished goto end
.\sleep 3
set /a n+=1
rem If n is still 1, this is a pre-NT system, which can't terminate a loop.
if %n% == 1 goto end
goto loop
:end
del bash.exe cp.exe cygwin1.dll mkdir.exe sed.exe repl_spec bash_init
del sleep.exe config_tool.exe nt_repl_spec pre_nt_repl_spec
if exist finished del finished
if %maketmp% == y rmdir \tmp

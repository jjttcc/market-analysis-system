@echo off
rem bash complains if it can't find a /tmp directory:
set maketmp=n
if not exist \tmp set maketmp=y
if %maketmp% == y md \tmp
%comspec% /c start /min .\bash bash_init %1 %2 %3 %4 %5 %6 %7 %8 %9
:loop
if exist c5 goto end
if exist finished goto end
echo cleaning up ...
.\sleep 2
%comspec% /c count
goto loop
:end
del c?
del bash.exe cp.exe cygwin1.dll mkdir.exe sed.exe repl_spec bash_init
del sleep.exe config_tool.exe nt_repl_spec pre_nt_repl_spec count.bat
del finished
if %maketmp% == y rmdir \tmp

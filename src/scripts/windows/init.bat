if not exist c:\autoexec.bat goto end
echo set MAS_DIRECTORY=%1\lib >>c:\autoexec.bat
echo set PATH=%%PATH%%;%1\bin >>c:\autoexec.bat
:end

del install_tool.exe
del repl_spec
del mctrc
del install\nt_repl_spec
del install\pre_nt_repl_spec
rd install
if exist os_is_nt del cleanup.bat os_is_nt

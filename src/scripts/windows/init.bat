echo init.bat is running in:>repl_spec
rem set line_=%line_:"=%
cd>>repl_spec
echo replacestart>>repl_spec
echo {application_directory}"%1">>repl_spec
echo replaceend>>repl_spec
:end

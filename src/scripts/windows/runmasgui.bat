echo off
rem Run the mas GUI - connect with the server started with runmas
rem If a parameter is passed in, it will be used as the port number;
rem otherwise a hard-coded number will be used.

set port=18273
if not "%1"=="" set port=%1
cd %MAS_DIRECTORY%
cd classes
java MA_Client localhost %port%

@echo off
if exist c1 goto c2
echo >c1
goto end
:c2
if exist c2 goto c3
echo >c2
goto end
:c3
if exist c3 goto c4
echo >c3
goto end
:c4
if exist c4 goto c5
echo >c4
goto end
:c5
echo >c5
goto end
:end

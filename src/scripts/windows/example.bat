   @Echo Off
    If :'==%1' If Not %2'==' Goto %2
    Set | Find "winbootdir=" > NUL
    If ErrorLevel 1 If Not %OS%'==Windows_NT' For %%C In (Echo Goto:End) Do %%C Windows 9x/NT/2K Batch File.
    If Not %1'==/?' Goto Begin
    Echo Renames all file names in current dir to lower case file names.
    Echo.
    Echo Lowname
    Goto End
   :Begin
    Echo Rename all file names in current dir to lower case file names?
    Echo.
    Echo Press [Ctrl-C] to cancel or:
    Pause
    If Not %OS%'==Windows_NT' Goto Win9x
    For /F "tokens=*" %%F In ('Dir /B /L') Do Move "%%F" "%%F"
    Goto End
   :Win9x
    LfnFor On
    For %%F In (*.*) Do Call %0 : Mc2lc "%%F"
    LfnFor Off
    If Exist %TEMP%.\Tmp.bat Del %TEMP%.\Tmp.bat
    For %%V In (Mix Low) Do Set %%Vcase=
    Goto End
   :Mc2lc (Mixcase-to-Lowcase)
    For %%F In (%3) Do Set Mixcase=%%F
    Ren "%Mixcase%" "Set Lowcase=%Mixcase%"
    Dir /B /L "Set Lowcase=%Mixcase%" > %TEMP%.\Tmp.bat
    Call %TEMP%.\Tmp.bat
    Ren "Set Lowcase=%Mixcase%" "%Lowcase%"
   :End

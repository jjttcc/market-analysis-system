rem "Mailer" for MAS that simply copies its input to a file

set outfile=c:\mas_mail
%MAS_DIRECTORY%\..\bin\simple_cat >>%outfile%

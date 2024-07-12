@ECHO OFF

REM --- If you did not use the installer for the raptor-json-compiler, you have to set your
REM --- path to it manually here - DO NOT USE ANY "QUOTES"!
SET JSON_COMPILER=raptor-json-compiler.exe

REM --- DO NOT MODIFY THE SCRIPT BELOW THIS LINE!
REM ---------------------------------------------
SET VTXT=%~dp0\notes\version\version.txt
SET VJSN=%~dp0\datafiles\version.json

ECHO Updating build number...
IF NOT EXIST %VTXT% GOTO SKIP

for /f "delims== tokens=1,2" %%G in (%VTXT%) do set %%G=%%H
SET /A BUILD=BUILD+1
(ECHO { "version": "%MAJOR%.%MINOR%.%BUILD%", "major": %MAJOR%, "minor": %MINOR%, "build": %BUILD%}) >%VJSN%
(ECHO MAJOR=%MAJOR%&ECHO MINOR=%MINOR%&ECHO BUILD=%BUILD%) >%VTXT%

IF [%YYconfig%]==[Default] GOTO COMPILE
SET OPT=%~dp0\options
frep %OPT%\html5\options_html5.yy """option_html5_version""" "  ""option_html5_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l
frep %OPT%\windows\options_windows.yy """option_windows_version""" "  ""option_windows_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l
frep %OPT%\android\options_android.yy """option_android_version""" "  ""option_android_version"":""%MAJOR%.%MINOR%.%BUILD%.0""," -l

GOTO COMPILE

:SKIP
ECHO No version.txt found!

:COMPILE
IF [%YYconfig%]==[Default] GOTO END
IF [%YYconfig%]==[unit_testing] GOTO END

ECHO Compiling included files...
%JSON_COMPILER% %~dp0 %YYconfig%

GOTO END

:END
ECHO Buildnumber update completed.
@ECHO OFF

SET BINPATH=..\..\bin\windows\
SET FILENAME=minigui.inc

:: compilo el ejemplo
%BINPATH%\bgdc.exe -g test.prg

IF NOT ERRORLEVEL 2 GOTO right
IF ERRORLEVEL 2 GOTO wrong

:right
%BINPATH%\bgdi.exe test.dcb
del "release\%FILENAME%"
type "readme.txt" >> "release\%FILENAME%"
type "prg\gui-globals.prg" >> "release\%FILENAME%"
type "prg\gui-funciones.prg" >> "release\%FILENAME%"
type "prg\gui-control-*.prg" >> "release\%FILENAME%"

GOTO end

:wrong
pause
GOTO end

:end
del "test.dcb"

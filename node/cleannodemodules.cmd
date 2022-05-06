@echo off
REM cleannodemodules.cmd
REM Recursively deletes all node_modules folders under the current path

setlocal enabledelayedexpansion

FOR /d /r . %%d in (node_modules) DO @IF EXIST "%%d" echo %%d && rd /s /q %%d

endlocal

exit /b %ERRORLEVEL%

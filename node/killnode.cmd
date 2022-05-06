@echo off
REM killnode.cmd
REM Kills all running instances of node.exe

setlocal enabledelayedexpansion

call taskkill /f /im:node.exe

endlocal

exit /b %ERRORLEVEL%

@echo off
REM killnode.cmd
REM Kills all running instances of msbuild.exe, cl.exe, and link.exe

setlocal enabledelayedexpansion

call taskkill /f /im:msbuild.exe
call taskkill /f /im:cl.exe
call taskkill /f /im:link.exe

endlocal

exit /b %ERRORLEVEL%

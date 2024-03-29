@echo off
REM deletebranch.cmd <branch1> [<branch2>...]
REM Delete's branches in your repo both locally and remotely
REM
REM Options:
REM
REM branch  The name of the branch(es) to delete
REM
REM Requirements:
REM - Your repo has a remote at "origin"

setlocal enabledelayedexpansion

call where /q git
if %ERRORLEVEL% neq 0 (
    @echo deletebranch.cmd: git could not be found
    exit /b %ERRORLEVEL%
)

if "%~1"=="" (
  @echo deletebranch.cmd: Specify branch^(es^) to delete
  exit /b 1
)

:delete
if "%~1"=="" goto :end
set branch=%~1
git branch -D %branch% && git branch -dr origin/%branch%
shift
goto :delete

:end
endlocal

exit /b %ERRORLEVEL%

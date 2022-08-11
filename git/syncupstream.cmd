@echo off
REM syncupstream.cmd <branch>
REM Syncs your fork's <branch> both locally and remotely with the upstream repo's <branch>
REM
REM Options:
REM
REM branch  The name of the branch to sync
REM
REM Requirements:
REM - Your fork is at the remote "origin" and the upstream repo is at the remote "upstream"

setlocal enabledelayedexpansion

call where /q git
if %ERRORLEVEL% neq 0 (
    @echo %~nx0: git could not be found
    exit /b %ERRORLEVEL%
)

if "%~1"=="" (
  @echo %~nx0: Branch not specified
  exit /b 1
)
set branch=%~1

call git fetch --recurse-submodules upstream && git checkout --force %branch% && git merge upstream/%branch% && git push -u origin %branch%

if %ERRORLEVEL% neq 0 (
  @echo %~nx0: Unable to sync branch "%branch%" to "upstream/%branch%"
)

endlocal

exit /b %ERRORLEVEL%

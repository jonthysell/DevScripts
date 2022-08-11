@echo off
REM cleanslns.cmd [path]
REM Runs msbuild /clean on all solution files in the given path
REM
REM Options:
REM
REM path        The path to search and clean (default: current)

setlocal enabledelayedexpansion

call where /q msbuild
if %ERRORLEVEL% neq 0 (
    @echo %~nx0: msbuild could not be found
    exit /b %ERRORLEVEL%
)

set target_path=%CD%

:loop
set part=%1
if not "%part%"=="" (
  if "%part:~0,1%"=="/" (
      @echo %~nx0: Unknown flag "%part%"
      exit /b 1
  ) else (
      set target_path=%part%
  )
  shift
  goto :loop
)
:loopend

pushd %target_path%

for /r %%i in (*.sln) do (
    @echo %~nx0: Cleaning "%%i"
  call msbuild "%%i" /t:Clean
)

popd

endlocal

exit /b %ERRORLEVEL%

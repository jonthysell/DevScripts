@echo off
REM cleanbins.cmd [/recursive] [path]
REM Deletes all uncommited files (except node_modules and certificates) in the given git repo
REM
REM Options:
REM
REM path        The path of the git repo to clean (default: current)
REM /recursive  Recursively clean each subfolders of the given path

setlocal enabledelayedexpansion

call where /q git
if %ERRORLEVEL% neq 0 (
    @echo %~nx0: git could not be found
    exit /b %ERRORLEVEL%
)

set recursive=0

set target_path=%CD%

:loop
set part=%1
if not "%part%"=="" (
  if "%part%"=="/recursive" (
      set recursive=1
  ) else if "%part:~0,1%"=="/" (
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

if "%recursive%"=="0" (
  call :clean
) else (
  for /d %%i in (*.*) do (
    pushd %%i
    call :clean
    popd
  )
)

popd
goto :end

:clean
if not exist ".git/" (
  @echo %~nx0: Path "%cd%" is not a git repo
) else (
  @echo %~nx0: Cleaning "%cd%"
  call git clean -f -d -e node_modules/ -e *.pfx -e Package.StoreAssociation.xml -x
)
exit /b %ERRORLEVEL%

:end

endlocal

exit /b %ERRORLEVEL%

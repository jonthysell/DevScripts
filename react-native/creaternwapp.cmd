@echo off
REM creaternwapp.cmd [name]
REM Creates a RNW app using the new arch template
REM
REM Options:
REM
REM name            The name of the app to create (default: testapp)
REM /r [version]    Use react@version (default: latest)
REM /rn [version]   Use react-native@version (default: latest)
REM /rnw [version]  Use react-native-windows@version (default: latest)
REM /linkrnw        Use your local RNW repo at RNW_ROOT
REM
REM Requirements:
REM - You've set the RNW_ROOT environment variable with the path to your clone

setlocal enableextensions enabledelayedexpansion

if "%RNW_ROOT%"=="" (
  @echo creaternwapp.cmd: RNW_ROOT environment variable must be set
  exit /b 1
)

set APP_NAME=testapp
set RNW_TEMPLATE_TYPE=cpp-app

set R_VERSION=latest
set RN_VERSION=latest
set RNW_VERSION=latest
set LINK_RNW=0

:loop
set part=%1
set param=%2
if not "%part%"=="" (
  if "%part%"=="/linkrnw" (
      set LINK_RNW=1
  ) else if "%part%"=="/r" (
      set R_VERSION=%param%
      shift
  ) else if "%part%"=="/rn" (
      set RN_VERSION=%param%
      shift
  ) else if "%part%"=="/rnw" (
      set RNW_VERSION=%param%
      shift
  ) else if "%part%"=="/lt" (
      set RN_TEMPLATE_TYPE=%param%
      shift
  ) else if "%part:~0,1%"=="/" (
      @echo creaternwapp.cmd: Unknown flag "%part%"
      exit /b 1
  ) else (
      set APP_NAME=%part%
  )
  shift
  goto :loop
)
:loopend

if %LINK_RNW% equ 1 (
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" peerDependencies.react') do @set R_VERSION=%%a
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" peerDependencies.react-native') do @set RN_VERSION=%%a
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" version') do @set RNW_VERSION=%%a
)

@echo creaternwapp.cmd Creating RNW app "%APP_NAME%" with react@%R_VERSION%, react-native@%RN_VERSION%, and react-native-windows@%RNW_VERSION%

@echo creaternwapp.cmd: Creating base RN app project with: npx --yes react-native@%RN_VERSION% init %APP_NAME% --template react-native@%RN_VERSION%
call npx --yes react-native@%RN_VERSION% init %APP_NAME% --template react-native@%RN_VERSION%

if %ERRORLEVEL% neq 0 (
  @echo creaternwapp.cmd: Unable to create base RN app project
  exit /b %ERRORLEVEL%
)

pushd %APP_NAME%
call yarn install

@echo creaternwapp.cmd: Creating commit to save current state
if not exist ".git\" call git init .
call git add .
call git commit -m "call npx --yes react-native@%RN_VERSION% init %APP_NAME% --template react-native@%RN_VERSION%"

@echo creaternwapp.cmd: Upgrading RN
call yarn upgrade react@%R_VERSION%
call yarn upgrade react-native@%RN_VERSION%

@echo creaternwapp.cmd: Adding RNW dependency to app
call yarn add react-native-windows@%RNW_VERSION%

if %LINK_RNW% equ 1 (
  @echo creaternwapp.cmd: Linking RNW dependency to local repo
  pushd %RNW_ROOT%\vnext
  call yarn link
  popd
  call yarn link react-native-windows
)

call yarn install

@echo creaternwapp.cmd: Creating commit to save current state
call git add .
call git commit -m "add rnw dependency"

@echo creaternwapp.cmd Running init-windows with: yarn react-native init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging
call yarn react-native init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging

@echo creaternwapp.cmd Done, see new project in %APP_NAME%

endlocal

exit /b %ERRORLEVEL%
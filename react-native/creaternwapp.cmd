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
REM /lt [template]  Use template (default: cpp-app)
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

set R_VERSION=
set RN_VERSION=
set RNW_VERSION=
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
      set RNW_TEMPLATE_TYPE=%param%
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
  @echo creaternwapp.cmd Determining versions from local RNW repo at %RNW_ROOT%
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" peerDependencies.react') do @set R_VERSION=%%a
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" peerDependencies.react-native') do @set RN_VERSION=%%a
  for /f "delims=" %%a in ('npm show "%RNW_ROOT%\vnext" version') do @set RNW_VERSION=%%a
)

if "%RNW_VERSION%"=="" (
  @echo creaternwapp.cmd Defaulting react-native-windows version to latest
  set RNW_VERSION=latest
)

if "%RN_VERSION%"=="" (
  @echo creaternwapp.cmd Determining react-native version from react-native-windows dependency
  for /f "delims=" %%a in ('npm show react-native-windows@%RNW_VERSION% peerDependencies.react-native') do @set RN_VERSION=%%a
)

if "%R_VERSION%"=="" (
  @echo creaternwapp.cmd Determining react version from react-native-windows dependency
  for /f "delims=" %%a in ('npm show react-native-windows@%RNW_VERSION% peerDependencies.react') do @set R_VERSION=%%a
)

@echo creaternwapp.cmd Determining concrete versions for react@%R_VERSION%, react-native@%RN_VERSION%, and react-native-windows@%RNW_VERSION% 
for /f "delims=" %%a in ('npm show react-native-windows@%RNW_VERSION% version') do @set RNW_VERSION=%%a
for /f "delims=" %%a in ('npm show react-native@%RN_VERSION% version') do @set RN_VERSION=%%a
for /f "delims=" %%a in ('npm show react@%R_VERSION% version') do @set R_VERSION=%%a

@echo creaternwapp.cmd Creating RNW app "%APP_NAME%" with react@%R_VERSION%, react-native@%RN_VERSION%, and react-native-windows@%RNW_VERSION%

@echo creaternwapp.cmd: Creating base RN app project with: npx --yes @react-native-community/cli@latest init %APP_NAME% --version %RN_VERSION% --verbose --skip-install --install-pods false --skip-git-init true
call npx --yes @react-native-community/cli@latest init %APP_NAME% --version %RN_VERSION% --verbose --skip-install --install-pods false --skip-git-init true

if %ERRORLEVEL% neq 0 (
  @echo creaternwapp.cmd: Unable to create base RN app project
  exit /b %ERRORLEVEL%
)

pushd "%APP_NAME%"
call yarn install

@echo creaternwapp.cmd: Creating commit to save current state
if not exist ".git\" call git init .
call git add .
call git commit -m "npx --yes @react-native-community/cli@latest init %APP_NAME% --version %RN_VERSION% --verbose --skip-install --install-pods false --skip-git-init true"

@echo creaternwapp.cmd: Adding RNW dependency to app
call yarn add react-native-windows@%RNW_VERSION%

if %LINK_RNW% equ 1 (
  @echo creaternwapp.cmd: Linking RNW dependency to local repo
  if exist ".yarnrc.yml" (
    call yarn link %RNW_ROOT%\vnext
  ) else (
    pushd %RNW_ROOT%\vnext
    call yarn link
    popd
    call yarn link react-native-windows
  )
)

call yarn install

@echo creaternwapp.cmd: Creating commit to save current state
call git add .
call git commit -m "add rnw dependency"

@echo creaternwapp.cmd Running init-windows with: npx --yes @react-native-community/cli@latest init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging
call npx --yes @react-native-community/cli@latest init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging

@echo creaternwapp.cmd Done, see new %RNW_TEMPLATE_TYPE% project in %CD% with react@%R_VERSION%, react-native@%RN_VERSION%, and react-native-windows@%RNW_VERSION%

popd

endlocal

exit /b %ERRORLEVEL%
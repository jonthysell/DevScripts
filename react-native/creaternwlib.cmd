@echo off
REM creaternwlib.cmd [name]
REM Creates a RNW lib using the new arch template
REM
REM Options:
REM
REM name            The name of the app to create (default: testlib)
REM /r [version]    Use react@version (default: latest)
REM /rn [version]   Use react-native@version (default: latest)
REM /rnw [version]  Use react-native-windows@version (default: latest)
REM /lt [template]  Use template (default: module-new)
REM /linkrnw        Use your local RNW repo at RNW_ROOT
REM
REM Requirements:
REM - You've set the RNW_ROOT environment variable with the path to your clone

setlocal enableextensions enabledelayedexpansion

if "%RNW_ROOT%"=="" (
  @echo creaternwlib.cmd: RNW_ROOT environment variable must be set
  exit /b 1
)

set LIB_NAME=testlib
set RN_TEMPLATE_TYPE=module-new
set RNW_TEMPLATE_TYPE=cpp-lib

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
      @echo creaternwlib.cmd: Unknown flag "%part%"
      exit /b 1
  ) else (
      set LIB_NAME=%part%
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

@echo creaternwlib.cmd Creating RNW lib "%LIB_NAME%" with react@%R_VERSION%, react-native@%RN_VERSION%, and react-native-windows@%RNW_VERSION%

@echo creaternwlib.cmd Creating base RN library project with: npx --yes create-react-native-library@latest --slug %LIB_NAME% --description %LIB_NAME% --author-name "React-Native-Windows Bot" --author-email 53619745+rnbot@users.noreply.github.com --author-url http://example.com --repo-url http://example.com --languages java-objc --type %RN_TEMPLATE_TYPE% --react-native-version %RN_VERSION% %LIB_NAME%
call npx --yes create-react-native-library@latest --slug %LIB_NAME% --description %LIB_NAME% --author-name "React-Native-Windows Bot" --author-email 53619745+rnbot@users.noreply.github.com --author-url http://example.com --repo-url http://example.com --languages java-objc --type %RN_TEMPLATE_TYPE% --react-native-version %RN_VERSION% %LIB_NAME%

if %ERRORLEVEL% neq 0 (
  @echo creaternwlib.cmd: Unable to create base RN library project
  exit /b %ERRORLEVEL%
)

pushd %LIB_NAME%
call yarn install

@echo creaternwlib.cmd Adding RNW dependency to library
call yarn add react-native-windows@%RNW_VERSION% --dev
call yarn add react-native-windows@* --peer

if %LINK_RNW% equ 1 (
  @echo creaternwlib.cmd Linking RNW dependency to local repo
  call yarn link %RNW_ROOT%\vnext
)

call yarn install

@echo creaternwlib.cmd Creating commit to save current state
call git add .
call git commit -m "chore: add rnw dependency"

@echo creaternwlib.cmd Running init-windows with: yarn react-native init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging
call yarn react-native init-windows --template %RNW_TEMPLATE_TYPE% --overwrite --logging

@echo creaternwlib.cmd Done, see new project in %APP_NAME%

endlocal

exit /b %ERRORLEVEL%
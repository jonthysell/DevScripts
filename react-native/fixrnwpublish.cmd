@echo off

setlocal enableextensions enabledelayedexpansion

if "%RNW_ROOT%"=="" (
  @echo fixrnwpublish.cmd: RNW_ROOT environment variable must be set
  exit /b 1
)

if "%RNW_GH_TOKEN%"=="" (
  @echo fixrnwpublish.cmd: RNW_GH_TOKEN environment variable must be set
  exit /b 1
)

set branch=main

:loop
set part=%1
if not "%part%"=="" (
  if "%part:~0,1%"=="/" (
    @echo fixrnwpublish.cmd: Unknown flag "%part%"
    exit /b 1
  ) else (
    set branch=%part%
  )
  shift
  goto :loop
)

@echo fixrnwpublish.cmd: Fixing RNW publish for branch %branch%

call resetrnw.cmd /cleanbins %branch%

@echo fixrnwpublish.cmd: Have you elevated to repo administrator? https://repos.opensource.microsoft.com/orgs/microsoft/repos/react-native-windows
pause

@echo fixrnwpublish.cmd: Have you set RNW_GH_TOKEN to a working (Repository contents R/W) token? https://github.com/settings/tokens?type=beta
pause

pushd %RNW_ROOT%

@echo fixrnwpublish.cmd: Calling beachball publish for %branch%
call npx beachball publish --no-publish --branch upstream/%branch% -yes --bump-deps --verbose --access public --message "applying package updates ***NO_CI***"

if %ERRORLEVEL% neq 0 (
  @echo fixrnwpublish.cmd: Failure calling beachball publish
  exit /b %ERRORLEVEL%
)

@echo fixrnwpublish.cmd: Sync local branch with new commit for %branch%
call git pull upstream %branch%

@echo fixrnwpublish.cmd: Calling @rnw-scripts/create-github-releases for %branch%
if "%branch%"=="main" (
  call npx @rnw-scripts/create-github-releases --yes --authToken %RNW_GH_TOKEN%
) else (
  call npx --yes @rnw-scripts/create-github-releases@latest --yes --authToken %RNW_GH_TOKEN%
)

if %ERRORLEVEL% neq 0 (
  @echo fixrnwpublish.cmd: Failure calling @rnw-scripts/create-github-releases
  exit /b %ERRORLEVEL%
)

popd

@echo fixrnwpublish.cmd: Now kick off a new publish for %branch% with Skip NPM, Skip Git, Perform Beachball Check. https://dev.azure.com/microsoft/ReactNative/_build?definitionId=63081

endlocal

exit /b %ERRORLEVEL%

@echo off
REM resetrnw.cmd [/cleanbins] [/cleannode] [branch]
REM Resets your react-native-windows repo to a clean state for a given branch,
REM syncing your fork's branch with the official repo's branch
REM
REM Options:
REM
REM branch      The name of the branch to sync (default: main)
REM /cleanbins  Deletes all uncommited files (except node_modules and certificates)
REM /cleannode  Deletes all existing node_modules folders before running yarn
REM
REM Requirements:
REM - You've set the RNW_ROOT environment variable with the path to your clone
REM - Your fork is at the remote "origin" and the official repo is at the remote "upstream"

setlocal enableextensions enabledelayedexpansion

if "%RNW_ROOT%"=="" (
  echo resetrnw.cmd: RNW_ROOT environment variable must be set
  exit /b 1
)

set cleanbins=0
set cleannode=0

set branch=main

:loop

if not "%1"=="" (
    if "%1"=="/cleanbins" (
        set cleanbins=1
    ) else if "%1"=="/cleannode" (
        set cleannode=1
    ) else (
        set branch=%1
    )
    shift
    goto :loop
)
:loopend

echo resetrnw.cmd: Resetting RNW to branch "%branch%"

pushd %RNW_ROOT%

echo resetrnw.cmd: Changing to branch "%branch%"
call syncupstream.cmd %branch%

if %ERRORLEVEL% neq 0 (
  echo resetrnw.cmd: Unable to change to branch "%branch%"
  exit /b %ERRORLEVEL%
)

if "%cleanbins%"=="1" (
  echo resetrnw.cmd: Cleaning bins
  call cleanbins.cmd
  
  if %ERRORLEVEL% neq 0 (
    echo resetrnw.cmd: Unable to clean bins
    exit /b %ERRORLEVEL%
  )
)

if "%cleannode%"=="1" (
  echo resetrnw.cmd: Cleaning node_modules
  call cleannodemodules.cmd
  
  if %ERRORLEVEL% neq 0 (
    echo resetrnw.cmd: Unable to clean node_modules
    exit /b %ERRORLEVEL%
  )
)

echo resetrnw.cmd: Running yarn install
call yarn install

if %ERRORLEVEL% neq 0 (
  echo resetrnw.cmd: Failure running yarn install
  exit /b %ERRORLEVEL%
)

echo resetrnw.cmd: Running yarn build
call yarn build

if %ERRORLEVEL% neq 0 (
  echo resetrnw.cmd: Failure running yarn build
  exit /b %ERRORLEVEL%
)

git status

echo resetrnw.cmd: Successfully reset RNW to branch "%branch%"

popd

endlocal

exit /b %ERRORLEVEL%

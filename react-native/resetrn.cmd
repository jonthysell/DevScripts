@echo off
REM resetrn.cmd [/cleanbins] [/cleannode] [branch]
REM Resets your react-native repo to a clean state for a given branch,
REM syncing your fork's branch with the official repo's branch
REM
REM Options:
REM
REM branch      The name of the branch to sync (default: main)
REM /cleanbins  Deletes all uncommited files (except node_modules and certificates)
REM /cleannode  Deletes all existing node_modules folders before running yarn
REM
REM Requirements:
REM - You've set the RN_ROOT environment variable with the path to your clone
REM - Your fork is at the remote "origin" and the official repo is at the remote "upstream"

setlocal enableextensions enabledelayedexpansion

if "%RN_ROOT%"=="" (
  echo resetrn.cmd: RN_ROOT environment variable must be set
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

echo resetrn.cmd: Resetting RN to branch "%branch%"

pushd %RN_ROOT%

if "%cleanbins%"=="1" (
  echo resetrn.cmd: Cleaning bins
  call cleanbins.cmd
  
  if %ERRORLEVEL% neq 0 (
    echo resetrn.cmd: Unable to clean bins
    exit /b %ERRORLEVEL%
  )
)

if "%cleannode%"=="1" (
  echo resetrn.cmd: Cleaning node_modules
  call cleannodemodules.cmd
  
  if %ERRORLEVEL% neq 0 (
    echo resetrn.cmd: Unable to clean node_modules
    exit /b %ERRORLEVEL%
  )
)

echo resetrn.cmd: Changing to branch "%branch%"
call syncupstream.cmd %branch%

if %ERRORLEVEL% neq 0 (
  echo resetrn.cmd: Unable to change to branch "%branch%"
  exit /b %ERRORLEVEL%
)

echo resetrn.cmd: Running yarn install
call yarn install

if %ERRORLEVEL% neq 0 (
  echo resetrn.cmd: Failure running yarn install
  exit /b %ERRORLEVEL%
)

call git status

echo resetrn.cmd: Successfully reset RN to branch "%branch%"

popd

endlocal

exit /b %ERRORLEVEL%

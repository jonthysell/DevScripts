@echo off
REM cleanbins.cmd
REM Deletes all uncommited files (except node_modules and certificates) in the current repo

setlocal enabledelayedexpansion

call git clean -f -d -e node_modules/ -e *.pfx -e Package.StoreAssociation.xml -x

endlocal

exit /b %ERRORLEVEL%

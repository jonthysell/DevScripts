@echo off
REM gdiff.cmd [...]
REM Runs a directory diff with your git difftool for the current repo

setlocal

git difftool --dir-diff %*

endlocal

exit /b %ERRORLEVEL%

@echo off
REM gdifflast.cmd
REM Runs a directory diff with your git difftool for changes made by the last commit in the current repo

setlocal

call gdiff.cmd @~..@

endlocal

exit /b %ERRORLEVEL%

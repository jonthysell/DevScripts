@echo off
REM gdifflast.cmd
REM Runs a directory diff with your git difftool for the last commit the current repo

setlocal

call gdiff.cmd @~..@

endlocal

exit /b %ERRORLEVEL%

@echo off
REM gdiff.cmd [...]
REM Runs a directory diff with your git difftool for the current repo

setlocal

call where /q git
if %ERRORLEVEL% neq 0 (
    @echo %~nx0: git could not be found
    exit /b %ERRORLEVEL%
)

call git difftool --dir-diff %*

endlocal

exit /b %ERRORLEVEL%

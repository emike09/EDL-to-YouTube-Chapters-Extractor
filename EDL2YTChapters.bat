@echo off
:: EDL2YTChapters.bat
:: Drag and drop one or more .edl files onto this file to convert them.
:: Output .txt files appear in the same folder as each source EDL.
::
:: Requires: PowerShell 7+ (pwsh) and EDL-to-YouTube-Chapters.ps1
:: Both files must be in the same folder.

setlocal

:: Resolve the directory this .bat lives in
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%EDL-to-YouTube-Chapters.ps1"

:: Check that the PowerShell script is present
if not exist "%PS_SCRIPT%" (
    echo ERROR: EDL-to-YouTube-Chapters.ps1 not found in %SCRIPT_DIR%
    echo Make sure both files are in the same folder.
    pause
    exit /b 1
)

:: Build the argument list from all dropped files
set "ARGS="
:argloop
if "%~1"=="" goto run
set "ARGS=%ARGS% "%~1""
shift
goto argloop

:run
pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"%ARGS%

:: Keep window open so the user can read output
:: (The PS1 script also has its own "press any key" at the end,
::  but this catches any early exits before PS1 launches)
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Something went wrong. See error above.
    pause
)

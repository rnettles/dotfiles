@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem 1. Define Paths
rem The source is the local dotfiles repo containing the agent definitions
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "SOURCE_DIR=%SCRIPT_DIR%\.github\agents"
rem The target is the official global path for Copilot agents on Windows
set "TARGET_DIR=%USERPROFILE%\.copilot\agents"

echo Starting Copilot Agent sync...

rem 2. Create the target directory if it doesn't exist
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

rem 3. Create symbolic links, falling back to copies when symlinks are unavailable
if not exist "%SOURCE_DIR%\" (
    echo Error: Source directory "%SOURCE_DIR%" not found. Check repo structure.
    exit /b 1
)

set "FOUND_MATCH="
for %%F in ("%SOURCE_DIR%\*.agent.md") do (
    if exist "%%~fF" (
        set "FOUND_MATCH=1"
        set "TARGET_FILE=%TARGET_DIR%\%%~nxF"

        if exist "!TARGET_FILE!" del /f /q "!TARGET_FILE!" >nul 2>&1

        mklink "!TARGET_FILE!" "%%~fF" >nul 2>&1
        if errorlevel 1 (
            copy /y "%%~fF" "!TARGET_FILE!" >nul
            if errorlevel 1 (
                echo Error: Failed to sync %%~nxF
                exit /b 1
            )
            echo Synced %%~nxF using copy fallback.
        ) else (
            echo Linked %%~nxF
        )
    )
)

if not defined FOUND_MATCH (
    echo Error: No .agent.md files found in "%SOURCE_DIR%".
    exit /b 1
)

rem 4. Final verification of the synced files
dir "%TARGET_DIR%"

endlocal
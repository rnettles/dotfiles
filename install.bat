@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ================================================================
rem  Copilot Environment Setup — dotfiles/install.bat
rem
rem  1. Locate ai-project_template (sibling of this repo)
rem  2. Pull latest template from remote
rem  3. Sync *.agent.md  →  %USERPROFILE%\.copilot\agents\
rem ================================================================

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

rem ai-project_template lives as a sibling of the dotfiles repo
set "TEMPLATE_DIR=%SCRIPT_DIR%\..\ai-project_template"
set "AGENT_SOURCE=%TEMPLATE_DIR%\.github\agents"
set "TARGET_DIR=%USERPROFILE%\.copilot\agents"

rem ── 1. Verify template repo is present ───────────────────────────
if not exist "%TEMPLATE_DIR%\.git" (
    echo Error: ai-project_template not found at "%TEMPLATE_DIR%".
    echo Clone it as a sibling of this repo before running install.bat.
    exit /b 1
)

rem ── 2. Pull latest template ───────────────────────────────────────
echo Pulling latest ai-project_template...
pushd "%TEMPLATE_DIR%"
git pull --quiet --ff-only
if errorlevel 1 echo Warning: Could not fast-forward ai-project_template. Continuing with local version.
popd

rem ── 3. Sync agents to %%USERPROFILE%%\.copilot\agents ─────────────
echo.
echo Syncing Copilot agents...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

if not exist "%AGENT_SOURCE%\" (
    echo Error: Agent source "%AGENT_SOURCE%" not found.
    exit /b 1
)

set "FOUND_MATCH="
for %%F in ("%AGENT_SOURCE%\*.agent.md") do (
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
            echo   Synced %%~nxF [copy]
        ) else (
            echo   Linked %%~nxF
        )
    )
)

if not defined FOUND_MATCH (
    echo Error: No .agent.md files found in "%AGENT_SOURCE%".
    exit /b 1
)

echo.
echo Done. Agents available in: %TARGET_DIR%
echo To sync a project's AI dev stack, run:
echo   dotfiles\sync-project.bat ^<project-root-path^>

endlocal
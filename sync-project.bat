@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ================================================================
rem  AI Dev Stack Project Sync — dotfiles/sync-project.bat
rem
rem  Usage: sync-project.bat <project-root-path>
rem  Example: sync-project.bat C:\dev\code\cks-platform
rem
rem  Safe to re-run. Applies three-tier sync policy:
rem    always-sync  — policy files (overwrite on every run)
rem    seed-only    — project-configurable files (copy once, never overwrite)
rem    never-touch  — mutable agent state (AI_FIX_REQUEST.md, ai_state/, etc.)
rem ================================================================

if "%~1"=="" (
    echo Usage: sync-project.bat ^<project-root-path^>
    echo.
    echo Example: sync-project.bat C:\dev\code\cks-platform
    exit /b 1
)

set "PROJECT_DIR=%~1"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "TEMPLATE_DIR=%SCRIPT_DIR%\..\ai-project_template"
set "TMPL_GUIDANCE=%TEMPLATE_DIR%\ai_dev_stack\ai_guidance"
set "TMPL_STACK=%TEMPLATE_DIR%\ai_dev_stack"
set "PROJ_STACK=%PROJECT_DIR%\ai_dev_stack"
set "PROJ_GUIDANCE=%PROJECT_DIR%\ai_dev_stack\ai_guidance"
set "PROJ_TASKS=%PROJECT_DIR%\ai_dev_stack\ai_project_tasks"

if not exist "%PROJECT_DIR%\" (
    echo Error: Project directory not found: "%PROJECT_DIR%"
    exit /b 1
)

if not exist "%TEMPLATE_DIR%\.git" (
    echo Error: ai-project_template not found at "%TEMPLATE_DIR%"
    echo Run install.bat first to verify the template is available.
    exit /b 1
)

echo ================================================================
echo  Syncing AI dev stack
echo  Template : %TEMPLATE_DIR%
echo  Project  : %PROJECT_DIR%
echo ================================================================
echo.

rem ── Ensure ai_dev_stack structure exists ─────────────────────────
if not exist "%PROJ_STACK%"    mkdir "%PROJ_STACK%"
if not exist "%PROJ_GUIDANCE%" mkdir "%PROJ_GUIDANCE%"
if not exist "%PROJ_TASKS%"    mkdir "%PROJ_TASKS%"

rem ── ALWAYS-SYNC: policy guidance files (overwrite) ───────────────
echo [always-sync] Policy guidance...
for %%F in (
    AI_COMMIT_TEMPLATE.md
    AI_DESIGN_PROCESS.md
    AI_EXECUTION_ARTIFACT_NAMING.md
    AI_GOVERNANCE_PILOT_REVIEW.md
    AI_HANDOFF_CONTRACT.md
    AI_INTAKE_PROCESS.md
    AI_PHASE_PROCESS.md
    AI_PROMPT_STAGING_REFERENCE.md
    AI_REVIEW.md
    AI_RULES.md
    AI_RUNTIME_LOADING_RULES.md
    AI_RUNTIME_POLICY.md
    AI_SIDE_QUEST_PROCESS.md
    AI_STEP_HISTORY.md
    AI_TASK_FLAGS_CONTRACT.md
    AI_TASK.md
    AI_TEST_GUIDELINES.md
    COORDINATION_CONTEXT.md
) do (
    if exist "%TMPL_GUIDANCE%\%%F" (
        copy /y "%TMPL_GUIDANCE%\%%F" "%PROJ_GUIDANCE%\%%F" >nul
        echo   + %%F
    ) else (
        echo   ? %%F [not found in template]
    )
)

rem ── ALWAYS-SYNC: guidance schemas subfolder ──────────────────────
if exist "%TMPL_GUIDANCE%\schemas\" (
    if not exist "%PROJ_GUIDANCE%\schemas" mkdir "%PROJ_GUIDANCE%\schemas"
    for %%F in ("%TMPL_GUIDANCE%\schemas\*") do (
        copy /y "%%F" "%PROJ_GUIDANCE%\schemas\" >nul
        echo   + schemas\%%~nxF
    )
)

rem ── ALWAYS-SYNC: ai_dev_stack root docs ──────────────────────────
echo.
echo [always-sync] Stack root docs...
for %%F in (
    agent-architecture.md
    WORKFLOW_ONBOARDING.md
    autonomous_repo_setup_guide.md
    NEW_PROJECT_SETUP.md
) do (
    if exist "%TMPL_STACK%\%%F" (
        copy /y "%TMPL_STACK%\%%F" "%PROJ_STACK%\%%F" >nul
        echo   + %%F
    )
)

rem ── ALWAYS-SYNC: scripts (Python automation) ──────────────────────
echo.
echo [always-sync] Scripts...
if exist "%TMPL_STACK%\scripts\" (
    if not exist "%PROJ_STACK%\scripts" mkdir "%PROJ_STACK%\scripts"
    for %%F in ("%TMPL_STACK%\scripts\*") do (
        copy /y "%%F" "%PROJ_STACK%\scripts\" >nul
        echo   + scripts\%%~nxF
    )
)
if exist "%TMPL_STACK%\ai_scripts\" (
    if not exist "%PROJ_STACK%\ai_scripts" mkdir "%PROJ_STACK%\ai_scripts"
    for %%F in ("%TMPL_STACK%\ai_scripts\*") do (
        copy /y "%%F" "%PROJ_STACK%\ai_scripts\" >nul
        echo   + ai_scripts\%%~nxF
    )
)

rem ── SEED-ONLY: project-configurable guidance ──────────────────────
rem  These files have project-specific content. Copy once; never overwrite.
echo.
echo [seed-only] Project-configurable guidance...
for %%F in (AI_RUNTIME_GATES.md AI_RUNTIME_PATHS.md AI_CONTEXT.md) do (
    if not exist "%PROJ_GUIDANCE%\%%F" (
        if exist "%TMPL_GUIDANCE%\%%F" (
            copy /y "%TMPL_GUIDANCE%\%%F" "%PROJ_GUIDANCE%\%%F" >nul
            echo   + %%F [seeded]
        )
    ) else (
        echo   ~ %%F [skipped — project-owned]
    )
)

rem ── SEED-ONLY: document templates ────────────────────────────────
echo.
echo [seed-only] Document templates...
for %%F in ("%TMPL_STACK%\ai_project_tasks\TEMPLATE_*.md") do (
    if not exist "%PROJ_TASKS%\%%~nxF" (
        copy /y "%%F" "%PROJ_TASKS%\%%~nxF" >nul
        echo   + %%~nxF [seeded]
    ) else (
        echo   ~ %%~nxF [skipped — project-owned]
    )
)

rem Seed PROJECT_CONTEXT.md and next_steps.md once
for %%F in (PROJECT_CONTEXT.md next_steps.md) do (
    if not exist "%PROJ_TASKS%\%%F" (
        if exist "%TMPL_STACK%\ai_project_tasks\%%F" (
            copy /y "%TMPL_STACK%\ai_project_tasks\%%F" "%PROJ_TASKS%\%%F" >nul
            echo   + %%F [seeded]
        )
    ) else (
        echo   ~ %%F [skipped — project-owned]
    )
)

rem ── NEVER-TOUCH: mutable agent state ─────────────────────────────
rem  AI_FIX_REQUEST.md is written by agents during fix cycles.
rem  ai_state/*.json and history/ are live runtime state.
rem  These are NEVER synced or overwritten.
echo.
echo [never-touch] AI_FIX_REQUEST.md, ai_state/, history/ — skipped

rem ── SCAFFOLD: create mutable state folders if absent ─────────────
echo.
echo [scaffold] Mutable state folders...
for %%D in (
    ai_dev_stack\ai_project_tasks\active
    ai_dev_stack\ai_project_tasks\intake
    ai_dev_stack\ai_project_tasks\side_quests
    ai_dev_stack\ai_project_tasks\staged_sprints
    ai_dev_stack\ai_project_tasks\staged_phases
    ai_dev_stack\ai_project_tasks\ui_tests
    ai_dev_stack\ai_state
    ai_dev_stack\history\task_history
    ai_dev_stack\history\phase_history
) do (
    if not exist "%PROJECT_DIR%\%%D\" (
        mkdir "%PROJECT_DIR%\%%D"
        echo   + %%D [created]
    ) else (
        echo   ~ %%D [exists]
    )
)

echo.
echo ================================================================
echo  Sync complete: %PROJECT_DIR%
echo ================================================================

endlocal

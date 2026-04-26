#!/usr/bin/env bash
# ================================================================
#  AI Dev Stack Project Sync — dotfiles/sync-project.sh
#
#  Usage: bash sync-project.sh <project-root-path>
#  Example: bash sync-project.sh /workspaces/cks-platform
#
#  Applies three-tier sync policy:
#    always-sync  — policy files (overwrite on every run)
#    seed-only    — project-configurable files (copy once, never overwrite)
#    never-touch  — mutable agent state (AI_FIX_REQUEST.md, ai_state/, etc.)
# ================================================================
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: bash sync-project.sh <project-root-path>"
    echo "Example: bash sync-project.sh /workspaces/cks-platform"
    exit 1
fi

PROJECT_DIR="${1%/}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../ai-project_template" 2>/dev/null && pwd || echo "")"

if [ -z "$TEMPLATE_DIR" ] || [ ! -d "$TEMPLATE_DIR/.git" ]; then
    echo "Error: ai-project_template not found as a sibling of dotfiles."
    echo "Clone it at: $(dirname "$SCRIPT_DIR")/ai-project_template"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory not found: $PROJECT_DIR"
    exit 1
fi

TMPL_GUIDANCE="$TEMPLATE_DIR/ai_dev_stack/ai_guidance"
TMPL_STACK="$TEMPLATE_DIR/ai_dev_stack"
PROJ_STACK="$PROJECT_DIR/ai_dev_stack"
PROJ_GUIDANCE="$PROJECT_DIR/ai_dev_stack/ai_guidance"
PROJ_TASKS="$PROJECT_DIR/ai_dev_stack/ai_project_tasks"

echo "================================================================"
echo " Syncing AI dev stack"
echo " Template : $TEMPLATE_DIR"
echo " Project  : $PROJECT_DIR"
echo "================================================================"
echo ""

# Ensure structure exists
mkdir -p "$PROJ_STACK" "$PROJ_GUIDANCE" "$PROJ_TASKS"

# ── ALWAYS-SYNC: policy guidance files ───────────────────────────
echo "[always-sync] Policy guidance..."
ALWAYS_SYNC=(
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
)
for f in "${ALWAYS_SYNC[@]}"; do
    if [ -f "$TMPL_GUIDANCE/$f" ]; then
        cp -f "$TMPL_GUIDANCE/$f" "$PROJ_GUIDANCE/$f"
        echo "  + $f"
    else
        echo "  ? $f [not found in template]"
    fi
done

# ── ALWAYS-SYNC: schemas subfolder ───────────────────────────────
if [ -d "$TMPL_GUIDANCE/schemas" ]; then
    mkdir -p "$PROJ_GUIDANCE/schemas"
    cp -f "$TMPL_GUIDANCE/schemas/"* "$PROJ_GUIDANCE/schemas/" 2>/dev/null || true
    echo "  + schemas/*"
fi

# ── ALWAYS-SYNC: ai_dev_stack root docs ──────────────────────────
echo ""
echo "[always-sync] Stack root docs..."
for f in agent-architecture.md WORKFLOW_ONBOARDING.md autonomous_repo_setup_guide.md NEW_PROJECT_SETUP.md; do
    if [ -f "$TMPL_STACK/$f" ]; then
        cp -f "$TMPL_STACK/$f" "$PROJ_STACK/$f"
        echo "  + $f"
    fi
done

# ── ALWAYS-SYNC: scripts ──────────────────────────────────────────
echo ""
echo "[always-sync] Scripts..."
if [ -d "$TMPL_STACK/scripts" ]; then
    mkdir -p "$PROJ_STACK/scripts"
    cp -f "$TMPL_STACK/scripts/"* "$PROJ_STACK/scripts/" 2>/dev/null || true
    echo "  + scripts/*"
fi
if [ -d "$TMPL_STACK/ai_scripts" ]; then
    mkdir -p "$PROJ_STACK/ai_scripts"
    cp -f "$TMPL_STACK/ai_scripts/"* "$PROJ_STACK/ai_scripts/" 2>/dev/null || true
    echo "  + ai_scripts/*"
fi

# ── SEED-ONLY: project-configurable guidance ─────────────────────
echo ""
echo "[seed-only] Project-configurable guidance..."
for f in AI_RUNTIME_GATES.md AI_RUNTIME_PATHS.md AI_CONTEXT.md; do
    if [ ! -f "$PROJ_GUIDANCE/$f" ]; then
        if [ -f "$TMPL_GUIDANCE/$f" ]; then
            cp "$TMPL_GUIDANCE/$f" "$PROJ_GUIDANCE/$f"
            echo "  + $f [seeded]"
        fi
    else
        echo "  ~ $f [skipped — project-owned]"
    fi
done

# ── SEED-ONLY: document templates ────────────────────────────────
echo ""
echo "[seed-only] Document templates..."
for f in "$TMPL_STACK/ai_project_tasks/TEMPLATE_"*.md; do
    fname=$(basename "$f")
    if [ ! -f "$PROJ_TASKS/$fname" ]; then
        cp "$f" "$PROJ_TASKS/$fname"
        echo "  + $fname [seeded]"
    else
        echo "  ~ $fname [skipped — project-owned]"
    fi
done
for f in PROJECT_CONTEXT.md next_steps.md; do
    if [ ! -f "$PROJ_TASKS/$f" ] && [ -f "$TMPL_STACK/ai_project_tasks/$f" ]; then
        cp "$TMPL_STACK/ai_project_tasks/$f" "$PROJ_TASKS/$f"
        echo "  + $f [seeded]"
    else
        echo "  ~ $f [skipped — project-owned]"
    fi
done

# ── NEVER-TOUCH: mutable agent state ─────────────────────────────
echo ""
echo "[never-touch] AI_FIX_REQUEST.md, ai_state/, history/ — skipped"

# ── SCAFFOLD: create mutable state folders ────────────────────────
echo ""
echo "[scaffold] Mutable state folders..."
MUTABLE_DIRS=(
    "ai_dev_stack/ai_project_tasks/active"
    "ai_dev_stack/ai_project_tasks/intake"
    "ai_dev_stack/ai_project_tasks/side_quests"
    "ai_dev_stack/ai_project_tasks/staged_sprints"
    "ai_dev_stack/ai_project_tasks/staged_phases"
    "ai_dev_stack/ai_project_tasks/ui_tests"
    "ai_dev_stack/ai_state"
    "ai_dev_stack/history/task_history"
    "ai_dev_stack/history/phase_history"
)
for d in "${MUTABLE_DIRS[@]}"; do
    if [ ! -d "$PROJECT_DIR/$d" ]; then
        mkdir -p "$PROJECT_DIR/$d"
        echo "  + $d [created]"
    else
        echo "  ~ $d [exists]"
    fi
done

echo ""
echo "================================================================"
echo " Sync complete: $PROJECT_DIR"
echo "================================================================"

#!/bin/bash

# 1. Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 2. Ensure the target directory exists
mkdir -p ~/.copilot/agents

# 3. Use an absolute path from the script's own location
ln -sf "$DOTFILES_DIR/.github/agents/"*.agent.md ~/.copilot/agents/

echo "Agents linked from: $DOTFILES_DIR"

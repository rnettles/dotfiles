#!/bin/bash

# 1. Define Paths
# The source is where GitHub clones your dotfiles
SOURCE_DIR="$HOME/dotfiles/.github/agents"
# The target is the official global path for Copilot agents on Linux
TARGET_DIR="$HOME/.copilot/agents"

echo "Starting Copilot Agent sync..."

# 2. Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# 3. Create symbolic links
# Using -sf (symbolic, force) ensures existing links are updated
if [ -d "$SOURCE_DIR" ]; then
    ln -sf "$SOURCE_DIR"/*.agent.md "$TARGET_DIR"/
    echo "✅ Success: Agents linked from $SOURCE_DIR to $TARGET_DIR"
else
    echo "❌ Error: Source directory $SOURCE_DIR not found. Check repo structure."
fi

# 4. Final verification of the links
ls -la "$TARGET_DIR"

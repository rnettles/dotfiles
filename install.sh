#!/bin/bash

# 1. Create the target directory if it doesn't exist
mkdir -p ~/.copilot/agents

# 2. Create symbolic links from your dotfiles repo to the Copilot folder
# This ensures that if you 'git pull' updates, they reflect immediately.
ln -sf ~/dotfiles/.github/agents/*.agent.md ~/.copilot/agents/

echo "Copilot Agents synced successfully!"

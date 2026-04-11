#!/bin/bash

# 1. Create the target directory if it doesn't exist
mkdir -p ~/.github/agents

# 2. Create symbolic links from your dotfiles repo to the Github folder
# This ensures that if you 'git pull' updates, they reflect immediately.
ln -sf ~/dotfiles/.github/agents/*.agent.md ~/.github/agents/

echo "Github Agents synced successfully!"

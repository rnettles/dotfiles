# Explicitly iterate to handle hidden paths and wildcards safely
for file in ~/dotfiles/.github/agents/*.agent.md; do
    [ -e "$file" ] || continue
    ln -sf "$file" ~/.copilot/agents/
done

# Check if tmux is installed
if command -v tmux >/dev/null 2>&1; then
    # Check if the current shell is inside a tmux session
    if [[ -z "$TMUX" ]]; then
        # Check if a tmux session is already running
        if tmux has-session 2>/dev/null; then
            # Attach to the existing tmux session
            tmux attach-session
        else
            # Start a new tmux session
            tmux new-session
        fi
    fi
fi

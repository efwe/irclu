# Auto-attach to the shared tmux session on interactive login.
# A session is also started at container boot by the entrypoint.
if status is-interactive
    if not set -q TMUX
        if command -q tmux
            tmux attach -t irclu; or tmux new -s irclu
        end
    end
end

# Ensure good defaults for tmux sessions (WeeChat compatibility).
# Only change TERM when actually running inside tmux.
if set -q TMUX
    set -gx TERM tmux-256color
end

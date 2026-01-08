# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/xario/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/xario/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/xario/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/xario/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/xario/.lmstudio/bin"
# End of LM Studio CLI section

. "$HOME/.cargo/env"

# TTY-safe tmux wrapper: lets `tmux` work in non-interactive contexts
# If stdin/stdout/stderr are TTYs, run tmux normally.
# Otherwise, allocate a pseudo-TTY via `script` so tmux can start.
tmux_safe_wrapper() {
    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
        command tmux "$@"
        return
    fi
    if command -v script >/dev/null 2>&1; then
        # Safely quote args for the -c command string
        local args
        args=$(printf '%q ' "$@")
        args=${args% } # trim trailing space
        script -qfec "tmux ${args}" /dev/null
    else
        echo "tmux requires a TTY. Install 'script' (util-linux) or run in a real terminal." >&2
        return 1
    fi
}

# Use wrapper for the `tmux` command (opt-out: `command tmux ...`)
alias tmux=tmux_safe_wrapper

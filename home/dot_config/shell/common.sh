# Shared environment and aliases, sourced by both .bashrc (Linux) and
# .zshrc (macOS). Keep POSIX-compatible.

export EDITOR=nvim
export VISUAL=nvim

# mise shims aren't on PATH in non-interactive shells; ~/.local/bin holds
# mise itself and any static binaries (e.g. tmux on SLE).
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# CLICOLOR covers BSD ls; --color=auto covers GNU ls and recent macOS.
export CLICOLOR=1
if ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto'
fi
alias grep='grep --color=auto'

alias vi=nvim
alias vim=nvim
alias g=git
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -20'
alias ta='tmux attach || tmux new'

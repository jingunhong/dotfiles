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

# Binaries from `cargo install`; rustc/cargo themselves come via mise shims.
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) ;;
  *) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# SSH from a terminal the host's terminfo db doesn't know (e.g. Ghostty's
# xterm-ghostty on SLE) breaks backspace/arrows in every curses app; fall
# back to a universally known TERM. The real fix is copying the compiled
# entry from the local machine into the remote's ~/.terminfo/x/.
# Checked via the filesystem because infocmp may not be installed either.
_terminfo_known() {
  for _d in "$TERMINFO" "$HOME/.terminfo" /etc/terminfo /lib/terminfo /usr/share/terminfo; do
    [ -n "$_d" ] || continue
    # single letter on Linux, hex byte on macOS
    [ -e "$_d/${1%"${1#?}"}/$1" ] && return 0
    [ -e "$_d/$(printf '%02x' "'$1")/$1" ] && return 0
  done
  return 1
}
_terminfo_known "$TERM" || export TERM=xterm-256color
unset -f _terminfo_known

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

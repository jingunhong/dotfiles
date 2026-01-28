# ============================================
# Zsh Options
# ============================================
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # command correction (replaces ENABLE_CORRECTION)
setopt CORRECT_ALL          # correct all arguments
setopt HIST_IGNORE_DUPS     # no duplicate history
setopt HIST_IGNORE_SPACE    # ignore commands starting with space
setopt SHARE_HISTORY        # share history between sessions
setopt EXTENDED_GLOB        # extended globbing

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Case/hyphen insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# ============================================
# Completions (native zsh)
# ============================================
autoload -Uz compinit
compinit

# ============================================
# Plugins
# ============================================
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh


# ============================================
# Tools
# ============================================

# pyenv
eval "$(pyenv init -)"

# nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"

# ============================================
# Aliases
# ============================================
alias vi=nvim
alias vim=nvim
alias ls='ls --color=auto'
alias ll='ls -la'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'

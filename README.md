# dotfiles

Terminal-first dev environment managed by [chezmoi](https://chezmoi.io):
macOS terminal frontend → SSH → remote tmux → Neovim / Claude Code / shell.
tmux on the remote host is the session persistence layer; everything installs
into `$HOME` — no root needed anywhere.

| Concern | Tool |
|---|---|
| Dotfiles | chezmoi |
| Multiplexer | tmux (system package, or static binary in `~/.local/bin` on no-root SLE) |
| Runtimes + CLI tools | mise (python, node, neovim ≥ 0.12, ripgrep, fd, fzf, delta, uv, tree-sitter) |
| Editor | Neovim, kickstart-derived config on `vim.pack` (fzf-lua, oil.nvim, gitsigns, mason; clangd + basedpyright + ruff) |
| Diff review | delta as git pager |
| macOS Homebrew | GUI apps, fonts, and tmux ONLY |

## Setup

On any fresh machine (Linux or macOS):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jingunhong/dotfiles
```

This installs chezmoi into `~/.local/bin`, clones this repo, prompts once for
the machine role and git identity, applies all dotfiles, installs mise, and
runs `mise install` for the whole toolchain. Safe to re-run.

You will be prompted for:

- **Machine role** — one of:
  - `suse` — SUSE Linux Enterprise host, no root; a static tmux is
    downloaded to `~/.local/bin` if the system has none
  - `ubuntu` — small Ubuntu VM (limited RAM; footprint kept light)
  - `mac` — macOS laptop
- **Git author name / email** — written into `~/.gitconfig`

Non-interactive (e.g. provisioning scripts):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jingunhong/dotfiles \
  --promptString "Machine role (suse / ubuntu / mac)=ubuntu" \
  --promptString "Git author name=Jingun Hong" \
  --promptString "Git author email=jingun.hong@gmail.com"
```

Then restart your shell (or `exec $SHELL -l`) so mise activation takes effect,
and start Neovim once — `vim.pack` clones plugins and mason installs the LSP
servers (clangd, basedpyright, ruff) on first launch.

### Prerequisites the bootstrap checks but does not install

- **C compiler** (`cc`/`gcc`/`clang`) — needed by nvim-treesitter to build
  parsers. macOS: `xcode-select --install`. Ubuntu:
  `sudo apt install build-essential`. SLE without root: request via your
  admin/dev-tools channel.
- **tmux** on Ubuntu — `sudo apt install tmux`. (On `suse` the bootstrap
  installs a static binary automatically; on `mac` it comes via the Homebrew
  step below.)
- **Claude Code** — installs via its native installer, not mise:

  ```sh
  curl -fsSL https://claude.ai/install.sh | bash
  ```

### macOS extras (Homebrew: GUI apps, fonts, tmux — nothing else)

If Homebrew is present, the bootstrap installs these automatically
(`run_once_after_25-macos-apps`); otherwise install brew first
(https://brew.sh), then:

```sh
brew install tmux
brew install --cask wezterm ghostty font-caskaydia-cove-nerd-font font-caskaydia-mono-nerd-font
```

Both terminal frontends are configured the same way — CaskaydiaMono Nerd
Font (Cascadia Code), **bold as the default weight** — via the managed
`~/.config/wezterm/wezterm.lua` and `~/.config/ghostty/config`. Try both,
keep one, drop the other from the brew script. (cmux, if preferred, installs
via its own release — see https://github.com/manaflow-ai/cmux.)

**Important:** CLI dev tools are owned by mise, not brew. If brew-installed
duplicates exist (node, python, ripgrep, fd, fzf, delta, neovim, …),
uninstall them — e.g. `brew uninstall neovim ripgrep` — or make sure
`~/.local/share/mise` shims/activation precede `/opt/homebrew/bin` in `PATH`
(the shipped `.zshrc` already orders it that way for interactive shells).

## Daily use

```sh
chezmoi edit ~/.tmux.conf      # edit the source of a managed file
chezmoi diff                   # preview pending changes
chezmoi apply                  # apply them
chezmoi update                 # pull latest from this repo + apply
chezmoi cd                     # drop into the repo checkout
```

### Add or upgrade a tool

Edit the global mise config, apply, install:

```sh
chezmoi edit ~/.config/mise/config.toml
chezmoi apply
mise install
```

### Change the machine role or git identity

Answers are cached in `~/.config/chezmoi/chezmoi.toml`; re-prompt with:

```sh
chezmoi init --data=false   # asks the questions again
chezmoi apply
```

## Verify an install

```sh
chezmoi apply --dry-run --verbose        # should print nothing (idempotent)
mise doctor
for t in nvim rg fd fzf delta uv tree-sitter; do mise which $t; done
nvim '+checkhealth' # then :q — look for vim.pack / lsp / treesitter status
git log -p          # should page through delta
tmux                # split panes: prefix is C-a; C-a | vertical, C-a - horizontal
tmux show -g focus-events   # must be "on" (Neovim autoread of agent edits)
```

LSP expectations: Python files attach basedpyright + ruff out of the box;
C++ needs a `compile_commands.json` in the project root for clangd.

## Layout

```
.chezmoiroot                   # source root is home/
home/
├── .chezmoi.toml.tmpl         # role + git identity prompts (asked once)
├── .chezmoiignore             # .zshrc only on macOS, .bashrc only on Linux
├── dot_tmux.conf              # C-a prefix, vi copy mode, focus-events on
├── dot_gitconfig.tmpl         # delta as pager
├── dot_bashrc.tmpl            # Linux shells
├── dot_zshrc.tmpl             # macOS
├── dot_config/
│   ├── shell/common.sh        # shared aliases/env for both shells
│   ├── mise/config.toml       # the global toolchain — edit to add tools
│   ├── nvim/init.lua          # single-file kickstart-derived config
│   ├── wezterm/wezterm.lua    # macOS-only terminal frontend (bold Caskaydia)
│   └── ghostty/config         # ditto, for Ghostty
└── .chezmoiscripts/
    ├── run_once_before_10-install-mise.sh.tmpl
    ├── run_once_after_20-mise-install.sh.tmpl
    ├── run_once_after_25-macos-apps.sh.tmpl   # brew: tmux, wezterm, fonts
    └── run_once_after_30-checks.sh.tmpl       # compiler/tmux/claude checks
```

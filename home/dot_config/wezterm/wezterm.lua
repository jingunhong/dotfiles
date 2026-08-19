local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Bold as the default weight. Actual bold text then renders the same weight;
-- it stays distinguishable via bright ANSI colors (bold_brightens_ansi_colors
-- is on by default).
config.font = wezterm.font_with_fallback {
  { family = 'CaskaydiaMono Nerd Font', weight = 'Bold' },
  { family = 'CaskaydiaCove Nerd Font', weight = 'Bold' },
}
config.font_size = 13.0

-- Match the Neovim colorscheme
config.color_scheme = 'Tokyo Night'

config.hide_tab_bar_if_only_one_tab = true

return config

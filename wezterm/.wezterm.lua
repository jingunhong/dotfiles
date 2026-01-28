local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	initial_cols = 150,
	initial_rows = 50,
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	default_cursor_style = "BlinkingBar",
	color_scheme = "Catppuccin Mocha",
	font = wezterm.font("CaskaydiaMono Nerd Font Mono", { weight = "Bold" }),
	font_size = 20,
}

return config

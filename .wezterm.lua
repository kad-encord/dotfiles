-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
config.window_close_confirmation = "NeverPrompt"

config.term = "xterm-256color"

config.color_scheme = "Everforest Dark Soft (Gogh)"

-- Match darkvoid.nvim theme background

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.use_fancy_tab_bar = false

config.initial_cols = 100
config.initial_rows = 150

-- Disable title bar but enable resizable border
config.window_decorations = "RESIZE"

config.font_size = 15.5
config.font = wezterm.font("JetBrains Mono NL", { weight = "Regular", style = "Normal" })

-- Disable treating Alt as a modifier for commands
-- and let it work as a normal key
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

config.hide_tab_bar_if_only_one_tab = true

-- Enable clickable links
config.hyperlink_rules = {
	-- Match standard http/https URLs
	{
		regex = [[\bhttps?://[\w.-]+(?:\.[\w.-]+)+[/\w._~:/?#\[\]@!$&'()*+,;=%-]*\b]],
		format = "$0",
	},
	-- Match 'www' URLs without 'http'
	{
		regex = [[\bwww\.[\w.-]+(?:\.[\w.-]+)+[/\w._~:/?#\[\]@!$&'()*+,;=%-]*\b]],
		format = "https://$0",
	},
	-- Match emails
	{
		regex = [[\b[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}\b]],
		format = "mailto:$0",
	},
}

local act = wezterm.action

config.keys = {
	-- Move tabs
	{ key = "{", mods = "SHIFT|SUPER", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|SUPER", action = act.MoveTabRelative(1) },

	-- Pass Alt-j and Alt-k to Neovim
	{ key = "j", mods = "ALT", action = act.SendKey({ key = "j", mods = "ALT" }) },
	{ key = "k", mods = "ALT", action = act.SendKey({ key = "k", mods = "ALT" }) },
	{ key = "h", mods = "ALT", action = act.SendKey({ key = "h", mods = "ALT" }) },
	{ key = "l", mods = "ALT", action = act.SendKey({ key = "l", mods = "ALT" }) },
}

return config

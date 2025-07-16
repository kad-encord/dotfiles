-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()
config.window_close_confirmation = "NeverPrompt"
config.term = "xterm-256color"
-- Enable automatic config reloading
config.automatically_reload_config = true
-- Watch for theme preference file changes
local function watch_theme_file()
	local pref_file = wezterm.home_dir .. "/.config/nvim/theme_preference"
	wezterm.add_to_config_reload_watch_list(pref_file)
end
-- Call the watch function
watch_theme_file()
-- Function to load theme from file
local function load_theme()
	local pref_file = wezterm.home_dir .. "/.config/nvim/theme_preference"
	local pref_f = io.open(pref_file, "r")
	if pref_f then
		local theme = pref_f:read("all"):gsub("%s+", "")
		pref_f:close()
		-- Apply theme based on preference
		if theme == "dark" then
			config.color_scheme = "Everforest Dark (Gogh)"
		else
			config.color_scheme = "Everforest Light (Gogh)"
		end
		return config
	end
	-- Final fallback to light theme
	config.color_scheme = "Everforest Light (Gogh)"
	return config
end
-- Apply the dynamic theme
config = load_theme()
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
config.hyperlinkrules = {
	-- Match standard http/https URLs
	{
		regex = [[\bhttps?://[\w.-]+(?:\.[\w.-]+)+[/\w.~:/?#\[\]@!$&'()+,;=%-]\b]],
		format = "$0",
	},
	-- Match 'www' URLs without 'http'
	{
		regex = [[\bwww\.[\w.-]+(?:\.[\w.-]+)+[/\w._~:/?#\[\]@!$&'()+,;=%-]*\b]],
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
	-- Manual reload config for testing
	{ key = "r", mods = "SUPER|SHIFT", action = act.ReloadConfiguration },
}
return config

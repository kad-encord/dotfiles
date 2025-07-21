-- Function to determine if we're in a tmux session
local function in_tmux()
	return os.getenv("TMUX") ~= nil
end

-- Function to write theme configurations
local function setup_theme_files()
	local config_dir = vim.fn.stdpath("config")
	local tmux_dark_theme = config_dir .. "/tmux_dark.conf"
	local tmux_light_theme = config_dir .. "/tmux_light.conf"
	local wezterm_dir = vim.fn.expand("$HOME/.config/wezterm")
	vim.fn.system("mkdir -p " .. wezterm_dir)

	-- Write tmux themes (Everforest colors)
	local dark_tmux_config = [[
# Dark mode (Everforest dark soft)
set -g status-bg '#2d353b' 
set -g status-fg '#d3c6aa'
set -g status-right '#[fg=#7fbbb3]#[bg=#2d353b] %H:%M '
set -g window-status-format "#[fg=#859289, bg=#2d353b] #I #[fg=#d3c6aa, bg=#2d353b] #W "
set -g window-status-current-format "#[fg=#7fbbb3, bg=#3d484d] #I #[fg=#d3c6aa, bg=#3d484d] #W "
set -g status-left '#[fg=#a7c080, bg=#2d353b] #S #[default]'
]]

	local light_tmux_config = [[
# Light mode (Everforest light soft)
set -g status-bg '#e5dfc5' 
set -g status-fg '#e5e6c5'
set -g status-right '#[fg=#35a77c]#[bg=#f3efdf] %H:%M '
set -g window-status-format "#[fg=#708089, bg=#e5e6c5] #I #[fg=#5c6a72, bg=#f3efdf] #W "
set -g window-status-current-format "#[fg=#35a77c, bg=#edeada] #I #[fg=#5c6a72, bg=#edeada] #W "
set -g status-left '#[fg=#8da101, bg=#f3efdf] #S #[default]'
]]

	-- Write WezTerm theme files (Everforest colors)
	-- local wezterm_dark_config = [[
	-- local function apply_theme(config)
	-- 	config.color_scheme = "EverforestDark"
	-- 	return config
	-- end
	--
	-- return apply_theme
	-- ]]
	--
	-- local wezterm_light_config = [[
	-- local function apply_theme(config)
	-- 	config.color_scheme = "EverforestLight"
	-- 	return config
	-- end
	--
	-- return apply_theme
	-- ]]

	-- Write all files
	local files = {
		[tmux_dark_theme] = dark_tmux_config,
		[tmux_light_theme] = light_tmux_config,
		-- [wezterm_dir .. "/wezterm_dark.lua"] = wezterm_dark_config,
		-- [wezterm_dir .. "/wezterm_light.lua"] = wezterm_light_config,
	}

	for filepath, content in pairs(files) do
		local file = io.open(filepath, "w")
		if file then
			file:write(content)
			file:close()
		end
	end
end

-- Save current theme preference and update WezTerm
local function save_theme_preference(background)
	local config_dir = vim.fn.stdpath("config")
	-- local wezterm_dir = vim.fn.expand("$HOME/.config/wezterm")
	local pref_file = config_dir .. "/theme_preference"

	-- Save theme preference
	local file = io.open(pref_file, "w")
	if file then
		file:write(background)
		file:close()
	end

	-- Write WezTerm theme pointer file
	-- local wezterm_theme_file = wezterm_dir .. "/wezterm_theme.lua"
	-- local theme_path = wezterm_dir .. "/wezterm_" .. background .. ".lua"
	-- file = io.open(wezterm_theme_file, "w")
	-- if file then
	-- 	file:write(theme_path)
	-- 	file:close()
	-- end

	-- Also write to WezTerm colorscheme file (legacy compatibility)
	-- local wezterm_colorscheme_file = wezterm_dir .. "/colorscheme"
	-- local wezterm_scheme = background == "dark" and "EverforestDark" or "EverforestLight"
	-- file = io.open(wezterm_colorscheme_file, "w")
	-- if file then
	-- 	file:write(wezterm_scheme)
	-- 	file:close()
	-- end
end

-- Load saved theme preference
local function load_theme_preference()
	local config_dir = vim.fn.stdpath("config")
	local pref_file = config_dir .. "/theme_preference"
	local file = io.open(pref_file, "r")
	if file then
		local theme = file:read("*all"):gsub("%s+", "") -- Remove whitespace
		file:close()
		return theme
	end
	return "dark" -- Default
end

-- Function to reload WezTerm configuration
-- local function reload_wezterm()
-- 	-- Touch the theme preference file to trigger WezTerm's file watcher
-- 	local pref_file = vim.fn.expand("~/.config/nvim/theme_preference")
-- 	-- Update the file's modification time
-- 	vim.fn.system("touch " .. pref_file)
--
-- 	-- Also try the CLI reload as backup
-- 	vim.fn.system("wezterm cli reload-config 2>/dev/null &")
-- end

-- Set up files on startup
setup_theme_files()

-- Apply saved theme on startup
local preferred_theme = load_theme_preference()
if preferred_theme ~= vim.o.background then
	vim.o.background = preferred_theme
	save_theme_preference(preferred_theme)
end

-- Function to toggle theme
function _G.ToggleTheme()
	local config_dir = vim.fn.stdpath("config")
	local tmux_dark_theme = config_dir .. "/tmux_dark.conf"
	local tmux_light_theme = config_dir .. "/tmux_light.conf"

	-- Toggle Neovim theme
	local new_theme
	if vim.o.background == "dark" then
		new_theme = "light"
		vim.o.background = new_theme
		-- Update tmux if in tmux
		if in_tmux() then
			vim.fn.system("tmux source-file " .. tmux_light_theme)
		end
	else
		new_theme = "dark"
		vim.o.background = new_theme
		-- Update tmux if in tmux
		if in_tmux() then
			vim.fn.system("tmux source-file " .. tmux_dark_theme)
		end
	end

	-- Save the current theme preference and update WezTerm
	save_theme_preference(new_theme)

	-- Force WezTerm to reload - try multiple methods
	-- vim.defer_fn(function()
	-- 	reload_wezterm()
	-- end, 50)

	-- Print a message to confirm the theme change
	print("Theme changed to " .. vim.o.background .. "")
end

-- Set up the keybinding
vim.api.nvim_set_keymap("n", "<leader>ll", ":lua ToggleTheme()<CR>", { noremap = true, silent = true })

-- Create an autocommand to handle external background changes
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		-- Only proceed if not initial setup
		if vim.v.event.option ~= "background" then
			return
		end

		local config_dir = vim.fn.stdpath("config")
		local tmux_dark_theme = config_dir .. "/tmux_dark.conf"
		local tmux_light_theme = config_dir .. "/tmux_light.conf"
		local is_dark = vim.o.background == "dark"

		-- Save theme preference and update WezTerm
		save_theme_preference(is_dark and "dark" or "light")

		-- Update tmux if in tmux
		if in_tmux() then
			vim.fn.system("tmux source-file " .. (is_dark and tmux_dark_theme or tmux_light_theme))
		end

		-- Reload WezTerm configuration
		-- reload_wezterm()
	end,
})

return {
	"sainnhe/everforest",
	lazy = false,
	priority = 1000,
	config = function()
		-- Configure Everforest
		vim.g.everforest_background = "soft"
		vim.g.everforest_better_performance = 1
		vim.g.everforest_enable_italic = 1
		vim.g.everforest_disable_italic_comment = 0
		vim.g.everforest_transparent_background = 0
		vim.g.everforest_dim_inactive_windows = 0
		vim.g.everforest_sign_column_background = "none"
		vim.g.everforest_spell_foreground = "none"
		vim.g.everforest_ui_contrast = "low"
		vim.g.everforest_show_eob = 1
		vim.g.everforest_diagnostic_text_highlight = 0
		vim.g.everforest_diagnostic_line_highlight = 0
		vim.g.everforest_diagnostic_virtual_text = "grey"
		vim.g.everforest_current_word = "high contrast background"

		vim.cmd.colorscheme("everforest")
	end,
}

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

	-- Write tmux themes
	local dark_tmux_config = [[
# Dark mode (zenbones dark)
set -g status-bg '#1C1917' 
set -g status-fg '#B4BDC3'
set -g status-right '#[fg=#66A5AD]#[bg=#1C1917] %H:%M '
set -g window-status-format "#[fg=#888F94, bg=#1C1917] #I #[fg=#B4BDC3, bg=#1C1917] #W "
set -g window-status-current-format "#[fg=#66A5AD, bg=#3D4042] #I #[fg=#B4BDC3, bg=#3D4042] #W "
set -g status-left '#[fg=#819B69, bg=#1C1917] #S #[default]'
]]

	local light_tmux_config = [[
# Light mode (zenbones light)
set -g status-bg '#F0EDEC' 
set -g status-fg '#2C363C'
set -g status-right '#[fg=#3B8992]#[bg=#F0EDEC] %H:%M '
set -g window-status-format "#[fg=#4F5E68, bg=#F0EDEC] #I #[fg=#2C363C, bg=#F0EDEC] #W "
set -g window-status-current-format "#[fg=#3B8992, bg=#CBD9E3] #I #[fg=#2C363C, bg=#CBD9E3] #W "
set -g status-left '#[fg=#4F6C31, bg=#F0EDEC] #S #[default]'
]]

	local file = io.open(tmux_dark_theme, "w")
	if file then
		file:write(dark_tmux_config)
		file:close()
	end

	file = io.open(tmux_light_theme, "w")
	if file then
		file:write(light_tmux_config)
		file:close()
	end
end

-- Save current theme preference
local function save_theme_preference(background)
	local config_dir = vim.fn.stdpath("config")
	local pref_file = config_dir .. "/theme_preference"
	local file = io.open(pref_file, "w")
	if file then
		file:write(background)
		file:close()
	end

	-- Also write to WezTerm colorscheme file
	local wezterm_file = vim.fn.expand("$HOME/.config/wezterm/colorscheme")
	local wezterm_scheme = background == "dark" and "ZenbonesDark" or "ZenbonesLight"
	file = io.open(wezterm_file, "w")
	if file then
		file:write(wezterm_scheme)
		file:close()
	end
end

-- Load saved theme preference
local function load_theme_preference()
	local config_dir = vim.fn.stdpath("config")
	local pref_file = config_dir .. "/theme_preference"
	local file = io.open(pref_file, "r")
	if file then
		local theme = file:read("*all")
		file:close()
		return theme
	end
	return "dark" -- Default
end

-- Set up files on startup
setup_theme_files()

-- Apply saved theme on startup
local preferred_theme = load_theme_preference()
if preferred_theme ~= vim.o.background then
	vim.o.background = preferred_theme
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

	-- Save the current theme preference
	save_theme_preference(new_theme)

	-- Print a message to confirm the theme change
	print("Theme changed to " .. vim.o.background)
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

		-- Save theme preference
		save_theme_preference(is_dark and "dark" or "light")

		-- Update tmux if in tmux
		if in_tmux() then
			vim.fn.system("tmux source-file " .. (is_dark and tmux_dark_theme or tmux_light_theme))
		end
	end,
})

return {
	"zenbones-theme/zenbones.nvim",
	-- Optionally install Lush. Allows for more configuration or extending the colorscheme
	-- If you don't want to install lush, make sure to set g:zenbones_compat = 1
	-- In Vim, compat mode is turned on as Lush only works in Neovim.
	dependencies = "rktjmp/lush.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.g.zenbones_darken_comments = 45
		vim.cmd.colorscheme("zenbones")
	end,
}

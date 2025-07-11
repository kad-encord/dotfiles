return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- lazygit = {
		--   -- your lazygit configuration comes here
		--   -- or leave it empty to use the default settings
		--   -- refer to the configuration section below
		-- },
		picker = {
			formatters = {
				file = {
					truncate = 100,
				},
			},
			win = {
				input = {
					keys = {
						-- to close the picker on ESC instead of going to normal mode,
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["J"] = { "preview_scroll_down", mode = { "i", "n" } },
						["K"] = { "preview_scroll_up", mode = { "i", "n" } },
						["H"] = { "preview_scroll_left", mode = { "i", "n" } },
						["L"] = { "preview_scroll_right", mode = { "i", "n" } },
					},
				},
			},
			layout = {
				preview = "main",
				backdrop = 100,
				layout = {
					box = "vertical",
					backdrop = 100,
					width = 0,
					height = 0.2,
					position = "bottom",
					border = "top",
					title = " {title} {live} {flags}",
					title_pos = "left",
					{ win = "input", height = 1, border = "bottom", backdrop = 100 },
					{
						box = "horizontal",
						{ win = "list", border = "none", backdrop = 100 },
						{ win = "preview", title = "{preview}", width = 0.9, border = "left", backdrop = 100 },
					},
				},
			},
		},
	},
	styles = {},
	keys = {
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>st",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>sc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>sf",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>sr",
			function()
				Snacks.picker.recent({
					filter = {
						cwd = true,
					},
					matcher = {
						frecency = true, -- use frecency boosting
						history_bonus = true,
					},
				})
			end,
			desc = "Recent",
		},
		-- git
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.current()
			end,
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search History",
		},
		{
			"<leader>sC",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>sj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo History",
		},
		{
			"<leader>se",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
	},
}

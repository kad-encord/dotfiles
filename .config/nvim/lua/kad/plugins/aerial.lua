return {
	"stevearc/aerial.nvim",
	opts = {
		-- Position aerial window at bottom instead of right
		layout = {
			default_direction = "float",
			placement = "edge",
		},
		float = {
			border = "rounded",

			-- Determines location of floating window
			--   cursor - Opens float on top of the cursor
			--   editor - Opens float centered in the editor
			--   win    - Opens float centered in the window
			relative = "win",

			-- These control the height of the floating window.
			-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			-- min_height and max_height can be a list of mixed types.
			-- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
			max_height = 0.9,
			height = nil,
			min_height = { 8, 0.1 },

			override = function(conf, source_winid)
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				return conf
			end,
		},
		-- Auto-jump to symbol as you navigate (like LSP hover)
		autojump = true,
		-- Show aerial window at bottom
		position = "bottom",
	},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		-- Override default keybind if you want something else
		{ "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
	},
}

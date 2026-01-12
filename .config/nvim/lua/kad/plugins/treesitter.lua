return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			-- "windwp/nvim-autopairs",
		},
		config = function()
			-- Configure Treesitter
			local ts = require("nvim-treesitter.configs")
			ts.setup({
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
				ensure_installed = {
					"astro",
					"json",
					"javascript",
					"typescript",
					"tsx",
					"yaml",
					"html",
					"css",
					"scss",
					"markdown",
					"markdown_inline",
					"bash",
					"lua",
					"vim",
					"dockerfile",
					"gitignore",
					"python",
					"graphql",
					"jsdoc",
					"regex",
					"toml",
					"prisma",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				-- Optional: Enable autopairs integration with Treesitter
				autopairs = {
					enable = true,
				},
			})
			-- Configure nvim-autopairs
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = true, -- Enable Treesitter integration
			})
		end,
	},
}

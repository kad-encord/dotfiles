return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		-- "sindrets/diffview.nvim", -- optional - Diff integration

		"echasnovski/mini.pick", -- optional
	},
	config = true,

	keys = {
		{ "<leader>ng", "<cmd>Neogit<cr>", desc = "Neo[g]it Dashboard" },
	},

	sort_branches = "committerdate",

	sections = {
		recent = {
			folded = false,
		},
	},
}

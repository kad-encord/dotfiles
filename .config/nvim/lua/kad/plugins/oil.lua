return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		optional = true,
	},
	opts = {
		delete_to_trash = true,

		keymaps = {
			["q"] = "actions.close",
			[";"] = "actions.parent", -- Map ';' to go up a directory
		},
	},
	keys = {
		{
			"<leader>;",
			function()
				require("oil").open()
			end,
			desc = "Toggle Oil",
		},
		{
			"<leader>cd",
			function()
				require("oil").open(vim.fn.getcwd()) -- Open at project root instead of last dir
			end,
			desc = "Open Oil at project root",
		},
	},
}

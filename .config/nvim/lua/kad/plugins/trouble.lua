return {
	"folke/trouble.nvim",
	dependencies = {}, -- Remove unnecessary dependency if icons aren't used
	opts = {
		focus = true, -- Keep it focused for efficiency
	},
	cmd = "Trouble", -- Load the plugin only when the Trouble command is run
	keys = {
		{ "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
		{
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Open trouble document diagnostics",
		},
		{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" },
	},
}

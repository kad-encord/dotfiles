vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree plugin setup
return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			sort = {
				sorter = "case_sensitive",
			},
			view = {
				width = 35,
				side = "right", -- Set nvim-tree to open on the right
			},
			renderer = {
				group_empty = true,
				indent_markers = {
					enable = true,
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		-- Set up keymap for NvimTree
		local keymap = vim.api.nvim_set_keymap
		keymap("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
		keymap("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { noremap = true, silent = true })
		-- Keymapping for toggling nvim-tree visibility and focusing on the current file
		keymap("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { noremap = true, silent = true })
	end,
}

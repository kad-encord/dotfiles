return {
	"GeorgesAlkhouri/nvim-aider",
	cmd = "Aider",
	keys = {
		{ "<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
		{ "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
		{ "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
		{ "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
		{ "<leader>a+", "<cmd>Aider add<cr>", desc = "Add File" },
		{ "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
		{ "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
		{ "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
		-- Example nvim-tree.lua integration if needed
		{ "<leader>a+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
		{ "<leader>a-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
	},
	dependencies = {
		"folke/snacks.nvim",
		--- The below dependencies are optional
		"catppuccin/nvim",
		"nvim-tree/nvim-tree.lua",
		--- Neo-tree integration
		{
			"nvim-neo-tree/neo-tree.nvim",
			opts = function(_, opts)
				require("nvim_aider.neo_tree").setup(opts)
			end,
		},
	},
	config = function()
		-- Set up global autoread option required for auto_reload
		vim.o.autoread = true

		-- Set up Aider with custom configuration including auto_reload
		require("nvim_aider").setup({
			-- Enable auto-reload of changed buffers
			auto_reload = true,

			-- Your default Aider arguments
			args = {
				"--no-auto-commits",
				"--pretty",
				"--stream",
			},

			-- Other default settings will be preserved
		})

		-- Add terminal-specific mappings for Aider
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "*",
			callback = function(ev)
				local buf = ev.buf
				local buf_name = vim.api.nvim_buf_get_name(buf)

				if string.find(buf_name, "aider") then
					-- Map <Esc> to exit terminal mode
					vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = buf, noremap = true, silent = true })

					-- Add direct navigation from terminal mode
					vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { buffer = buf, noremap = true, silent = true })
					vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { buffer = buf, noremap = true, silent = true })
					vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { buffer = buf, noremap = true, silent = true })
					vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { buffer = buf, noremap = true, silent = true })
				end
			end,
		})
	end,
}

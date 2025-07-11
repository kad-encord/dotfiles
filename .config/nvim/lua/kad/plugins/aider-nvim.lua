return {
    -- Configuration for the Aider plugin, providing AI-assisted coding features
	"joshuavial/aider.nvim",
	config = function()
		-- Set global autoread option required for auto_reload
		vim.o.autoread = true

		-- Load the plugin with custom options
		require("aider").setup({
			auto_manage_context = true,
			default_bindings = true,
			debug = false,
			vim = true,
			ignore_buffers = {},

			border = {
				-- Rounded style for a more modern look
				style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- or e.g. "rounded"

				color = "#cba6f7", -- Purple from Catppuccin Mocha (Mauve)
			},
		})

		-- Add terminal-specific mappings for Aider terminal buffers
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "*",
			callback = function(ev)
				local buf = ev.buf
				local buf_name = vim.api.nvim_buf_get_name(buf)

				-- Check if this is an Aider buffer
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

		-- Force check for file changes more frequently for auto-reload
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave", "FocusGained" }, {
			pattern = "*",
			callback = function()
				if vim.fn.filereadable(vim.fn.expand("%")) == 1 then
					vim.cmd("checktime")
				end
			end,
		})
	end,
}

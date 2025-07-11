return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "stylelint" },
				scss = { "stylelint" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			log_level = vim.log.levels.DEBUG, -- Enable debugging
			log_file = "/tmp/conform.log", -- Path for logging

			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 3000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>ff", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 3000, -- Increased timeout to avoid djlint timeout errors
			})
		end, { desc = "Format file or range (in visual mode)" })

		-- Diagnostic command to check formatters
		vim.keymap.set("n", "<leader>cf", function()
			print(vim.inspect(conform.formatters_by_ft[vim.bo.filetype]))
		end, { desc = "Check attached formatters for current filetype" })
	end,
}

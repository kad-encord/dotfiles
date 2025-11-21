return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim", -- Ensure this loads after mason.nvim
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")
		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
		-- Defer the configuration of mason-lspconfig to allow mason.nvim to load first
		vim.defer_fn(function()
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = {
					"ts_ls",
					"html",
					"cssls",
					"tailwindcss",
					"lua_ls",
					"pyright",
					-- Added for React/Gatsby support:
					"jsonls",
					"graphql",
				},
				automatic_installation = true,
			})
		end, 100) -- Delay for 100ms, adjust if necessary
		-- Setup mason tool installer
		local mason_tool_installer = require("mason-tool-installer")
		mason_tool_installer.setup({
			ensure_installed = {
				"prettierd", -- Faster prettier daemon (replaces prettier)
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				"graphql-language-service-cli", -- GraphQL tooling
			},
		})
	end,
}

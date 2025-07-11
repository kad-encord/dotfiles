return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim", -- Add the base mason plugin
		"williamboman/mason-lspconfig.nvim", -- Add this dependency explicitly
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Import mason first
		local mason = require("mason")

		-- Setup mason first
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap

		-- Setup mason-lspconfig after mason
		mason_lspconfig.setup({
			-- A list of servers to automatically install if they're not already installed
			ensure_installed = {
				"pyright",
				"ts_ls",
				"tailwindcss",
				"cssls",
				"html",
				"emmet_ls",
				"lua_ls",
				"eslint",
				"jsonls",
				"graphql",
			},
			-- Whether servers that are set up (via lspconfig) should be automatically installed
			automatic_installation = true,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				local opts = { buffer = ev.buf, silent = true }
				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", vim.lsp.buf.references, opts)
				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- -- Change the Diagnostic symbols in the sign column (gutter)
		-- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		-- for type, icon in pairs(signs) do
		-- 	local hl = "DiagnosticSign" .. type
		-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		-- end

		-- In Neovim 0.11.1, we'll use the recommended handler approach for safety
		-- Define server configurations
		local servers = {
			pyright = {
				filetypes = { "python" },
			},
			ts_ls = {
				filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
			},
			tailwindcss = {
				filetypes = { "html", "typescriptreact", "javascriptreact" },
			},
			cssls = {
				filetypes = { "css", "scss" },
			},
			html = {
				filetypes = { "html", "typescriptreact", "javascriptreact" },
			},
			emmet_ls = {
				filetypes = { "html", "typescriptreact", "javascriptreact" },
			},
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
			eslint = {
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			},
			jsonls = {
				filetypes = { "json", "jsonc" },
			},
			graphql = {
				filetypes = { "graphql", "gql", "javascript", "typescript" },
			},
		}

		-- Setup all servers with our defined configurations
		for server_name, server_config in pairs(servers) do
			-- Add capabilities to each server config
			server_config.capabilities = capabilities

			-- Setup the language server with the combined configuration
			lspconfig[server_name].setup(server_config)
		end
	end,
}

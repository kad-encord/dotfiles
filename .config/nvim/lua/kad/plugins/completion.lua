return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"rafamadriz/friendly-snippets", -- useful snippets
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			config = function()
				-- Configure LuaSnip to avoid visual selection behavior
				require("luasnip").config.set_config({
					updateevents = "TextChanged,TextChangedI",
					region_check_events = "CursorMoved",
					delete_check_events = "TextChanged,InsertLeave",
					-- Keep cursor in insert mode, don't use select mode
					store_selection_keys = "<Tab>",
				})
				-- Load friendly-snippets
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
	},
	opts = {
		keymap = {
			preset = "default",
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = {
				function(cmp)
					if cmp.snippet_active() then
						return cmp.snippet_forward()
					else
						return cmp.select_next()
					end
				end,
				"fallback",
			},
			["<S-Tab>"] = {
				function(cmp)
					if cmp.snippet_active() then
						return cmp.snippet_backward()
					else
						return cmp.select_prev()
					end
				end,
				"fallback",
			},
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					score_offset = 100, -- Prioritize LSP
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					score_offset = 3,
				},
				snippets = {
					name = "Snippets",
					module = "blink.cmp.sources.snippets",
					score_offset = -3,
				},
				buffer = {
					name = "Buffer",
					module = "blink.cmp.sources.buffer",
					score_offset = -5,
				},
			},
		},
		completion = {
			menu = {
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			ghost_text = {
				enabled = false,
			},
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
		},
		snippets = {
			expand = function(snippet)
				require("luasnip").lsp_expand(snippet)
			end,
			active = function(filter)
				if filter and filter.direction then
					return require("luasnip").jumpable(filter.direction)
				end
				return require("luasnip").in_snippet()
			end,
			jump = function(direction)
				require("luasnip").jump(direction)
			end,
		},
		signature = {
			enabled = true,
		},
	},
	opts_extend = { "sources.default" },
}

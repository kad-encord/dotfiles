return {
	"saghen/blink.cmp",
	version = "*",
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
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "buffer" },
			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					score_offset = 100, -- Prioritize LSP
					transform_items = function(ctx, items)
						return vim.tbl_filter(function(item)
							-- Filter out bracket-only snippets that conflict with auto-brackets
							-- Check both label and text fields
							local label = item.label or ""
							local text = item.insertText or (item.textEdit and item.textEdit.newText) or ""

							-- Filter bracket completions: (), {}, [], etc.
							if item.kind == 15 then -- Snippet kind
								-- Check label for exact bracket pairs
								if label:match("^[%(%[%{][%)%]%}]$") then
									return false
								end
								-- Check text for bracket patterns
								if text ~= "" and (text:match("^[%(%[%{][%)%]%}]$") or text:match("^[%(%[%{]%$%{.-%}[%)%]%}]$")) then
									return false
								end
							end

							local filetype = vim.bo.filetype
							if filetype == "javascriptreact" or filetype == "typescriptreact" then
								-- Check if user is typing after '<' (creating a tag)
								local line = ctx.line
								local col = ctx.cursor[2]
								local before_cursor = line:sub(1, col)

								-- If the character before the word is '<', allow HTML tag completions
								local typing_new_tag = before_cursor:match("<%s*[a-z]*$") or before_cursor:match("^[a-z]*$")

								-- Only filter HTML snippets if NOT creating a new tag
								if not typing_new_tag then
									-- Filter items with kind=15 (Snippet) that create HTML tags
									if item.kind == 15 and item.insertTextFormat == 2 then
										-- Filter if it matches pattern: <word>${...}</word>
										if text:match("^<[a-z]+>%${.+}</[a-z]+>$") then
											return false
										end
									end
								end
							end
							return true
						end, items)
					end,
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					score_offset = 3,
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
		signature = {
			enabled = true,
		},
	},
	opts_extend = { "sources.default" },
}

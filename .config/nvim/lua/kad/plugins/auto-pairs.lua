return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")

		-- configure autopairs
		autopairs.setup({
			check_ts = true, -- enable treesitter
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
				java = false, -- don't check treesitter on java
			},
			fast_wrap = {},
			disable_filetype = { "TelescopePrompt", "vim" },
		})

		-- Setup CR (Enter key) mapping manually
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")

		-- Add space between parentheses
		autopairs.add_rules({
			Rule(" ", " "):with_pair(function(opts)
				local pair = opts.line:sub(opts.col - 1, opts.col)
				return vim.tbl_contains({ "()", "[]", "{}" }, pair)
			end),
		})
	end,
}

return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "│", -- Character for the indentation guide
			smart_indent_cap = true, -- Avoid showing unnecessary guides for short lines
		},
		scope = {
			enabled = true, -- Highlight the current scope
			show_start = true, -- Show the start of the current scope
			show_end = true, -- Show the end of the current scope
		},
		exclude = {
			filetypes = { "help", "alpha", "dashboard", "NvimTree" }, -- Filetypes to exclude
			buftypes = { "terminal", "nofile" }, -- Buffer types to exclude
		},
	},
}

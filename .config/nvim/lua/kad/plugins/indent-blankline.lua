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
			enabled = false, -- Disable scope highlighting to avoid visual selection effect
		},
		exclude = {
			filetypes = { "help", "alpha", "dashboard", "NvimTree" }, -- Filetypes to exclude
			buftypes = { "terminal", "nofile" }, -- Buffer types to exclude
		},
	},
}

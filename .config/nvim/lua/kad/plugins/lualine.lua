return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = false, -- Disable icons to reduce overhead
					theme = "auto", -- Let the theme adapt automatically
					disabled_filetypes = { statusline = {}, winbar = {} },
					section_separators = "", -- No section separators
					component_separators = "", -- No component separators
					ignore_focus = {},
					always_divide_middle = true, -- Ensures the sections are well-spaced
					always_show_tabline = true, -- Keep tabline visible
					globalstatus = true, -- Always show statusline globally
					refresh = {
						statusline = 300, -- Increased refresh interval to reduce overhead
						tabline = 300, -- Increased refresh interval
						winbar = 300, -- Increased refresh interval
					},
				},
				sections = {
					lualine_a = {},
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filename", path = 1 }, -- Use relative file path
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{ "filename", path = 1 }, -- Relative file path for inactive sections
					},
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {}, -- Empty tabline to prevent unnecessary calculations
				winbar = {}, -- Empty winbar
				inactive_winbar = {},
				extensions = {},
			})
		end,
	},
}

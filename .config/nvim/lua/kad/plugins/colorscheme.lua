return {
	"sainnhe/everforest",
	lazy = false,
	priority = 1000,
	config = function()
		-- Configure Everforest
		vim.g.everforest_background = "soft"
		vim.g.everforest_better_performance = 1
		vim.g.everforest_enable_italic = 1
		vim.g.everforest_disable_italic_comment = 0
		vim.g.everforest_transparent_background = 0
		vim.g.everforest_dim_inactive_windows = 0
		vim.g.everforest_sign_column_background = "none"
		vim.g.everforest_spell_foreground = "none"
		vim.g.everforest_ui_contrast = "low"
		vim.g.everforest_show_eob = 1
		vim.g.everforest_diagnostic_text_highlight = 0
		vim.g.everforest_diagnostic_line_highlight = 0
		vim.g.everforest_diagnostic_virtual_text = "grey"
		vim.g.everforest_current_word = "high contrast background"

		-- Set default background (change to "light" if you prefer)
		vim.o.background = "dark"

		vim.cmd.colorscheme("everforest")
	end,
}

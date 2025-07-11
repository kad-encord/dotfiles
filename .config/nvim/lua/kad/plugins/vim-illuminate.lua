return {
	"RRethy/vim-illuminate",
	event = { "BufReadPost", "BufNewFile" }, -- Load on buffer read or creation
	config = function()
		-- Configure vim-illuminate
		require("illuminate").configure({
			delay = 200, -- Delay in milliseconds
			filetypes_denylist = { "NvimTree", "TelescopePrompt" }, -- Disable for specific filetypes
			under_cursor = true, -- Highlight under the cursor
		})
	end,
}

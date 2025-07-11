local opt = vim.opt

-- opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
-- opt.autoindent = true -- copy indent from current line when starting new one

-- turn off line wrap
opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true
vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "#928374" })
vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#928374" })

opt.termguicolors = true
opt.background = "light" -- colorschemes that can be light or dark will be made light
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Function to highlight yanked text
local function highlight_yank()
	-- Define the highlight group for yanked text
	vim.highlight.on_yank({
		higroup = "IncSearch",
		timeout = 300,
		on_macro = true,
		on_visual = true,
	})
end

-- Create an autocommand group
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })

-- Create the autocommand
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = highlight_yank,
	group = highlight_group,
	pattern = "*",
})

-- BUFFER MANAGEMENT --
-- Disables hidden buffers to ensure buffers are always visible and explicitly managed.
-- This configuration also re-enables necessary features, like auto-saving, cursor position restoration,
-- that are affected by disabling hidden buffers and persists the undo history.

-- vim.o.hidden = false -- disable hidden buffers

-- Save modified files when leaving
-- vim.api.nvim_create_autocmd("BufLeave", {
-- 	callback = function()
-- 		if vim.bo.modified then
-- 			vim.cmd("silent! w") -- Save the file silently without showing messages
-- 		end
-- 	end,
-- })

-- Automatically save and restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local last_pos = vim.fn.line("'\"")
		-- Check if the last position is valid and within the file
		if last_pos > 0 and last_pos <= vim.fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})

-- Enable persistent undo history
opt.undofile = true
local undo_dir = vim.fn.expand("~/.local/share/nvim/undo")
if not vim.fn.isdirectory(undo_dir) then
	vim.fn.mkdir(undo_dir, "p")
end
vim.opt.undodir = undo_dir

-- Disable undo history for temporary files (e.g., files in /tmp/)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "/tmp/*",
	callback = function()
		vim.opt_local.undofile = false
	end,
})

-- Automatically override :q behavior to close nvim-tree if it's open
vim.api.nvim_create_autocmd("QuitPre", {
	pattern = "*",
	callback = function()
		-- Check if nvim-tree is open in any window
		local nvim_tree_open = false
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if buf_name:match("NvimTree_") then
				nvim_tree_open = true
				break
			end
		end

		-- If nvim-tree is open, quit all buffers (like :qa)
		if nvim_tree_open then
			vim.cmd("qa") -- Quit all buffers, including nvim-tree
		end
	end,
})

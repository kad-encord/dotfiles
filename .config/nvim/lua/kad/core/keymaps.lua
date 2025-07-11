vim.g.mapleader = " "

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Copy file path to clipboard
keymap(
	"n",
	"<leader>o",
	[[:lua print("Copied file path to clipboard: " .. vim.fn.expand("%")) vim.fn.setreg("+", vim.fn.expand("%"))<CR>]],
	opts
)

-- Change without yanking
keymap("n", "c", '"_c', opts)
keymap("n", "C", '"_C', opts)
keymap("v", "c", '"_c', opts)
keymap("v", "C", '"_C', opts)

-- Yank entire file to system clipboard
keymap("n", "<leader>y", ":%y+<CR>", opts)

-- Remap 'p' and 'P' in Visual mode to delete to black hole and then paste:
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })
vim.keymap.set("v", "P", '"_dP', { noremap = true, silent = true })

-- Select entire document
keymap("n", "<leader>sa", "ggVG", opts)

-- Go back a word with backspace
keymap("n", "<BS>", "b", opts)
keymap("v", "<BS>", "b", opts)

-- Write file with leader w
vim.keymap.set("n", "<leader>w", function()
	vim.cmd("write")
end, { noremap = true, silent = true })

-- Quit with leader q
keymap("n", "<leader>q", ":q<CR>", opts)

-- Clear search highlighting
keymap("n", "<leader>h", ":nohl<CR>", opts)

-- Window management
keymap("n", "<leader>sv", "<C-w>v", opts) -- Split vertically
keymap("n", "<leader>sh", "<C-w>s", opts) -- Split horizontally
keymap("n", "<leader>se", "<C-w>=", opts) -- Make split windows equal width & height

-- Fugitive
keymap("n", "<leader>gb", ":Git blame<CR>", opts)

-- Centre cursor when moving to search result
keymap("n", "n", "nzz", { silent = true })
keymap("n", "N", "Nzz", { silent = true })

-- Resize panes with Alt + hjkl
keymap("n", "<M-l>", ":vertical resize -2<CR>", opts)
keymap("n", "<M-h>", ":vertical resize +2<CR>", opts)
keymap("n", "<M-k>", ":resize -2<CR>", opts)
keymap("n", "<M-j>", ":resize +2<CR>", opts)

vim.keymap.set("n", "<leader>dh", function()
	vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics on hover" })

vim.keymap.set("n", "<leader>gg", function()
	require("snacks.lazygit").open()
end, { desc = "Open LazyGit via Snacks", noremap = true, silent = true })

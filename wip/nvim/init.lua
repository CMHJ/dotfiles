-- Set leader to space, don't know what maplocalleader is though
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Set options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.shiftwidth = 4

-- Disable Ex mode, if you know you know
vim.keymap.set("n", "Q", "<nop>")

-- netrw file explorer binds
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Open file explorer net
-- TODO: Add binding for simpler file create like 'f' instead of %
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Lexplore) -- Open small file explorer net to the side
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size
vim.g.netrw_liststyle = 1 -- ls -l style view
-- vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_sizestyle = "h" -- human readable file size

vim.keymap.set("n", "<leader>w", ":w<CR>") -- Write
vim.keymap.set("n", "<leader>q", ":q<CR>") -- Quit

-- Keep screen centred when moving around
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- When highlighting text in Select mode (not to be confused with Visual mode),
-- send it to the null register and replace it with what is in the default register.
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank and Delete into the system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- TODO: Add rest of primeagen bindings

vim.keymap.set("n", "<leader><leader>x", ":source %<CR>") -- Source current file 

-- Run line or highlighted section in lua
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Configure plugins using lazy
require('config.lazy')

-- Configure colourscheme - required to be after plugins are loaded
vim.cmd.colorscheme "dracula"

-- Make background transparent
vim.cmd([[
    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none
]])


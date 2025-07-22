-- Notes on Lua
-- - Array indexes start at 1.
-- - 0 is a truthy value.
-- - In lua files get treated as functions, so when including a file foo.lua with local foo = require('foo'),
--   whatever is returned at the end of that file will be assigned to the foo variable.
-- - With function calls, you can drop the parentheses if you are calling it with a single string literal or table,
--   e.g. print "Hello there!", or setup { default = 12, other = false }.
-- - .. is the concat operator for strings, e.g. "Hello " .. "there!"
-- - When defining a function on a table, you can use : instead of . as shorthand for inserting a self arg as first param:
--   ```lua
--   local myTable = {}
--
--   function myTable.something(self, ...) end
--   -- is the same as
--   function myTable:something(...) end
-- - setmetatable can be used to overwrite how default functionality of a table is handled, 
--   e.g. __add for adding two tables together.
--   ```
-- - Multiline text literals can be represented with square brackets: 
--   [[ 
--     Some
--     text
--     that continues
--     over lines.
--   ]]
--   Can also be used for keymappings where the " character can't be used, as it is being used to specify
--   a register.

-- Set leader to space, don't know what maplocalleader is though
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Set options
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true

-- Disable Ex mode, if you know you know
vim.keymap.set("n", "Q", "<nop>")

-- netrw file explorer binds
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Open file explorer net
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_banner = 0
-- vim.g.netrw_winsize = 25

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

vim.keymap.set("n", "<leader><leader>x", ":source %<CR>") -- Source current file 

-- Run line or highlighted section in lua
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Configure plugins using lazy
require('config.lazy')

-- Make background transparent
vim.cmd([[
    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none
]])


-- Set leader to space, don't know what maplocalleader is though
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Set options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.fixendofline = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir =  vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.colorcolumn = "80"

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

-- Install lazy nvim if it doesn't exist
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Add lazy into the runtime path for neovim so that the
-- lazy file required later in this file can be found.
vim.opt.runtimepath:prepend(lazypath)

-- Setup lazy.nvim plugins
require("lazy").setup({
  spec = {
    -- Colourschemes
    { "folke/tokyonight.nvim"},
    { "Mofiqul/dracula.nvim" },

    -- Tree-sitter configuration
    {
      "nvim-treesitter/nvim-treesitter",
      branch = 'master',
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require'nvim-treesitter.configs'.setup {
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
          auto_install = false,
          highlight = {
            enable = true,

            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            additional_vim_regex_highlighting = false,
          },
        }
      end
    }
  },
})

-- Configure colourscheme - required to be after plugins are loaded
vim.cmd.colorscheme "dracula"

-- Make background transparent
vim.cmd([[
    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none
]])

-- Filetype configurations

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Save autocmds
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")

    -- Trim trailing whitespace
    vim.cmd([[%s/\s\+$//e]])

    local current_buffer_idx = 0
    local total_lines = vim.fn.line("$")
    local last_line_content = vim.fn.getline(total_lines)

    -- Add newline to EOF if there isn't one
    if last_line_content ~= "" then
      vim.api.nvim_buf_set_lines(current_buffer_idx, total_lines, total_lines, true, { "" })
      total_lines = vim.fn.line("$")
    end

    -- Remove extra blank lines at EOF and check number of lines to prevent loop
    while total_lines > 1 and vim.fn.getline(total_lines - 1) == "" do
      vim.api.nvim_buf_set_lines(current_buffer_idx, total_lines - 1, total_lines, true, {})
      total_lines = vim.fn.line("$")
    end

    vim.fn.setpos(".", save_cursor)
  end,
})


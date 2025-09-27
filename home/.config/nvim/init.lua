-- TODOs:
-- - Remove dead code

-- Set leader to space, don't know what maplocalleader is though
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

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
      branch = "master",
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
    },

    -- LSP config
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        {
          "folke/lazydev.nvim",
          ft = "lua", -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
          },
        },
      },
      config = function ()
        vim.lsp.config("telescope", {
          extensions = {
            fzf = {}
          }
        })

        vim.lsp.config("lua_ls", {})
        vim.lsp.config("clangd", {})

        -- TODO: Cleanup this garbage

        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = { noremap=true, silent=true }
        vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
          vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })

          -- Mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end

        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = { 'lua_ls', 'clangd' }
        for _, lsp in pairs(servers) do
          require('lspconfig')[lsp].setup {
            on_attach = on_attach,
          }
        end
      end
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          -- "nvim-telescope/telescope-fzf-native.nvim",
          -- Fix here: https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/120#issuecomment-2929964883
          -- build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release",
        },
      },
      config = function()
        require("telescope").setup({
          defaults = {
            sorting_strategy = "ascending"
          },
        })
      end
    },

  },
})

-- Configure colourscheme - required to be after plugins are loaded
vim.cmd.colorscheme "dracula"

-- Make background transparent
-- vim.cmd([[
--     highlight Normal guibg=none
--     highlight NonText guibg=none
--     highlight Normal ctermbg=none
--     highlight NonText ctermbg=none
-- ]])

-- Set options
vim.opt.clipboard="unnamedplus" -- Use system clipboard for everything
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = true -- Stop the diagnostic column from appearing and disappearing constantly by just having it on

-- Remove annoying backup and swap defaults
vim.opt.swapfile = false
vim.opt.backup = false

-- Undo settings
vim.opt.undofile = true
vim.opt.undodir =  vim.fn.stdpath("data") .. "/undo"

-- Default indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Timeout
vim.opt.timeout = true
vim.opt.timeoutlen = 250 -- ms

-- Create highlighted columns in editor for line lengths
vim.opt.colorcolumn = {"80", "120"}

-- Disable Ex mode, if you know you know
-- Doesn't seem to have this behaviour in nvim but disable anyway
vim.keymap.set("n", "Q", "<nop>")

-- netrw file explorer binds and configuration
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Open file explorer net
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Lexplore) -- Open small file explorer net to the side
-- TODO: Add binding for simpler file create like 'f' instead of %
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size
vim.g.netrw_liststyle = 1 -- ls -l style view
-- vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_sizestyle = "h" -- human readable file size

vim.keymap.set("n", "<leader>w", ":w<CR>") -- Write
vim.keymap.set("n", "<leader>q", ":q<CR>") -- Quit

-- Telescope bindings
vim.keymap.set("n", "<leader>/", function()
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_ivy {
    -- winblend = 10,
    previewer = false,
  })
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
-- find files in neovim config
vim.keymap.set("n", "<leader>sn", function()
  require("telescope.builtin").find_files {
    cwd = "~/Repos/dotfiles/home/.config/nvim",
  }
end, { desc = "[S]earch [N]eovim config" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch Current [W]ord" })
vim.keymap.set("n", "<leader>sk", require("telescope.builtin").keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>st", require("telescope.builtin").builtin, { desc = "[S]earch [T]elescope builtin functions" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[S]earch [B]uffers"})
vim.keymap.set("n", "<leader>sm", function()
    -- For some reason only the first section is searched by default.
    require("telescope.builtin").man_pages { sections = { "ALL" } }
end, { desc = "[S]earch [M]an Pages" })
vim.keymap.set("n", "<leader>s.", require("telescope.builtin").oldfiles, { desc = "[S]earch Recent Files ('.' for repeat)" })

-- Quickfix list bindings
vim.keymap.set("n", "]q", "<cmd>cnext<CR>")
vim.keymap.set("n", "[q", "<cmd>cprev<CR>")
-- copen - to open quickfix list, because 'c' is for quickfix... it makes sense
-- clist - to temporarily show the quickfix list
-- cdo <cmd> - apply command to all items in the quickfix list like a sub cmd

-- Keep screen centred when moving around
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Use ctrl keys to move between panes
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Resize current window using -/_ and =/+ keys
vim.keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]])
vim.keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]])
-- vim.keymap.set("n", "+", [[<cmd>horizontal resize +5<cr>]])
-- vim.keymap.set("n", "_", [[<cmd>vertical resize -5<cr>]])
-- TODO: Add fullscreen toggle

-- Toggle relative line numbering, wo for "window option" as opt sets the option that only works on first load
vim.keymap.set("n", "<leader>l", function() vim.wo.relativenumber = not vim.wo.relativenumber end)

-- Find and replace current word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>]])
-- Find and replace currently highlighted text
vim.keymap.set("x", "<leader>s", [[y:%s/<C-r>"/<C-r>"/g<Left><Left>]])

-- Yank and Delete into the system clipboard
--vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
--vim.keymap.set("n", "<leader>Y", [["+Y]])

-- When highlighting text in Select mode (not to be confused with Visual mode),
-- send it to the null register and replace it with what is in the default register.
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("n", "<leader><leader>x", ":source %<CR>") -- Source current file

-- Set default run command to "build/<dir>", assumes that output binary is same name as directory.
local run_command = "./build/" .. vim.fs.basename(vim.fn.getcwd())
local term_buffer_id = 0

local term_ensure_open = function()
  -- Check if terminal window is visible
  local window_visible = false
  for _, window_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(window_id) == term_buffer_id then
      window_visible = true
    end
  end

  -- If window with terminal buffer doesn't exist create it
  if window_visible == false then
    vim.cmd.new() -- Create new window
    vim.cmd.wincmd("J") -- Move terminal to bottom position
    vim.api.nvim_win_set_height(0, 15)

    -- Use terminal buffer if it already exists but window was closed
    if vim.api.nvim_buf_is_loaded(term_buffer_id) and vim.bo[term_buffer_id].buftype == "terminal" then
      vim.api.nvim_set_current_buf(term_buffer_id)
    else
      -- Create new terminal buffer
      vim.cmd.term()
      term_buffer_id = vim.api.nvim_get_current_buf()
    end

    vim.cmd("normal! G") -- Move to the end of the terminal so that it scrolls with the output
    vim.cmd.wincmd("k") -- Move out of terminal window
  end
end

-- Terminal binds
vim.keymap.set("t", "<leader><C-c>", "<C-\\><C-n>") -- Escape terminal mode
vim.keymap.set("n", "<leader><leader>b", function() vim.opt.makeprg = vim.fn.input("!Build command: ") end)
vim.keymap.set("n", "<leader>b", "<cmd>make<CR>")
vim.keymap.set("n", "<leader><leader>r", function() run_command = vim.fn.input("!Run command: ") end)
vim.keymap.set("n", "<leader>r", function()
  term_ensure_open()
  local term_job_id = vim.b[term_buffer_id].terminal_job_id
  vim.fn.chansend(term_job_id, run_command .. "\n")
end)
vim.keymap.set("n", "<leader>t", function()
  term_ensure_open()
end)

-- Run line or highlighted section in lua
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- Move highlighted text up or down with Shift-j/k
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Maintain consistent word deletion in nvim insert mode as other GUI programs,
-- e.g. Ctrl-Backspace deletes word backwards
-- and Ctrl-Delete deletes word forwards.
-- vim.keymap.set("i", "<C-h>", "<C-w>") -- Disable in favour of movement binds
vim.keymap.set("i", "<C-Del>", "<C-o>de")

-- Use ctrl h or l to move left or right in Insert mode
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<C-h>", "<Left>")

-- Use ctrl h or l to move left or right in Command line mode
vim.keymap.set("c", "<C-l>", "<Right>")
vim.keymap.set("c", "<C-h>", "<Left>")

-- Navigate command history using Ctrl commands
vim.keymap.set("c", "<C-k>", "<Up>") -- Previous command
vim.keymap.set("c", "<C-j>", "<Down>") -- Next command

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


-- TODO
-- Remove dead code
-- Move keybinds into simple tables at the top
-- Add comment bind with C-/ or otherwise for gcc in normal mode and gc in highlight mode
-- Add binding for simpler file create like 'f' instead of % in netrw
-- Fix shell completion for build and run commands by adding options, something like ui_prompt?
-- Remove desc = ""
-- remove the lazy and priority stuff that doesn't do anything.
-- Setup telescope with harpoon for consistent windows.
-- Do lazy clean to remove unused plugins
-- Revert list of keybinds

-- Set global variables --

local theme = "default"

vim.g.mapleader = " " -- Set leader to spacebar.
vim.g.maplocalleader = "\\"

-- netrw file explorer configuration
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size.
vim.g.netrw_liststyle = 1 -- ls -l style view
-- vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_sizestyle = "h" -- human readable file size

-- Set options --

vim.opt.winborder = "rounded"
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for everything.
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes" -- Just keep sign column on to avoid annoying flicker.
vim.opt.autoread = true
vim.opt.swapfile = false -- Remove annoying backup and swap defaults.
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.tabstop = 4 -- Default indentation.
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.timeout = true -- Timeout
vim.opt.timeoutlen = 250 -- ms
vim.opt.colorcolumn = { "80", "120" } -- Create highlighted columns in editor for line lengths.

vim.o.winborder = "rounded"

-- Disable comment continuation on newline.
vim.api.nvim_create_autocmd("FileType", { pattern = "*", callback = function() vim.opt_local.formatoptions:remove({ 'r', 'o' }) end })

-- Automatically jump to last position in file and unfold lines when opened again.
vim.api.nvim_create_autocmd("BufReadPost", { pattern = "*", command = 'silent! normal! g`"zv' })

-- Custom Functions --

-- If the first argument is a directory, cd to that directory
local function is_dir(path) local stat = (vim.uv or vim.loop).fs_stat(path) return (stat ~= nil) and stat.type == "directory" end
if vim.fn.argc() > 0 and is_dir(vim.fn.argv(0)) then vim.cmd.cd(vim.fn.argv(0)) end

-- Set default run command to run.sh or "build/<dir>", assumes that output binary is same name as directory.
local run_command = nil
if vim.fn.executable("./run.sh") == 1 then run_command = "./run.sh" else run_command = "./build/" .. vim.fs.basename(vim.fn.getcwd()) end
if vim.fn.executable("./build.sh") == 1 then vim.opt.makeprg = "./build.sh" end

local function get_first_term_buf_id()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and
    vim.api.nvim_buf_is_loaded(buf) and
    vim.bo[buf].buftype == "terminal" then return buf end
  end
  return nil
end

-- Keybinds --
-- General Keybinds --

-- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>w", "<CMD>wa<CR>", { desc = "Save all buffers." })
vim.keymap.set("n", "<leader>wq", "<CMD>wa<CR><CMD>qa<CR>", { desc = "Save and quit all buffers." })
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode, if you know you know. Doesn't seem to have this behaviour in nvim but disable anyway." })

-- netrw file explorer binds --
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw file explorer." })
--vim.keymap.set("n", "<leader>pv", vim.cmd.Lexplore, { desc = "Open small file explorer to the side." })

-- Quickfix list bindings --
vim.keymap.set("n", "<leader>q",
  function()
    local quickfix_list_open = vim.fn.getqflist({winid = 0}).winid ~= 0
    if quickfix_list_open then vim.cmd("cclose") else vim.cmd("copen") end
  end,
  { desc = "Toggle Quickfix list, because 'c' is for quickfix... it makes sense." })
vim.keymap.set("n", "]q", "<CMD>cnext<CR>", { desc = "" })
vim.keymap.set("n", "[q", "<CMD>cprev<CR>", { desc = "" })
-- cdo <CMD> - apply command to all items in the quickfix list like a sub cmd

-- Diagnostics
vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count=1, float=true, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count=-1, float=true, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to previous error" })
vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

-- Keep screen centred when moving around
vim.keymap.set("n","<C-d>", "<C-d>zz", { desc = "" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "" })
vim.keymap.set("n", "n", "nzzzv", { desc = "" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center." })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Jump back and center." })
vim.keymap.set("n", "*", "*zz", { desc = "Search word under cursor and center." })
vim.keymap.set("n", "#", "#zz", { desc = "Search word under cursor backwards and center." })

vim.keymap.set("n", "]b", "<CMD>bnext<CR>", { desc = "Split horizontally." })
vim.keymap.set("n", "[b", "<CMD>bprev<CR>", { desc = "Split vertically." })
vim.keymap.set("n", "<leader>g", "<CMD>split<CR>", { desc = "Split horizontally." })
vim.keymap.set("n", "<leader>v", "<CMD>vsplit<CR>", { desc = "Split vertically." })

-- Resize current window using -/_ and =/+ keys
vim.keymap.set("n", "<Up>", [[<CMD>horizontal resize -2<CR>]], { desc = "" })
vim.keymap.set("n", "<Down>", [[<CMD>horizontal resize +2<CR>]], { desc = "" })
vim.keymap.set("n", "<Left>", [[<CMD>vertical resize -5<CR>]], { desc = "" })
vim.keymap.set("n", "<Right>", [[<CMD>vertical resize +5<CR>]], { desc = "" })
-- TODO: Add fullscreen toggle

vim.keymap.set("n", "<leader>l",
  function()
    vim.wo.number = not vim.wo.number
    vim.wo.relativenumber = not vim.wo.relativenumber
  end,
  { desc = "Toggle relative line numbering, wo for window option as opt sets the option that only works on first load." })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left>]], { desc = "Find and replace current word under cursor." })
vim.keymap.set("x", "<leader>s", [[y:%s/<C-r>"/<C-r>"/gc<Left><Left>]], { desc = "Find and replace currently highlighted text." })

-- Yank and Delete into the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Set null register." })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste from system clipboard over highlighted text and send overwritten text to null register." })
vim.keymap.set({ "i", "c" }, "<C-v>", [[<C-r>+]], { desc = "Paste from system clipboard." })

vim.keymap.set("n", "<leader><leader>x", "<CMD>source %<CR>", { desc = "Source current file." })

vim.keymap.set("n", "<leader>lg", "<CMD>LazyGit<CR>", { desc = "LazyGit" })
vim.keymap.set("n", "<leader>db", function() vim.cmd("silent !gf2 " .. run_command .. " &") end, { desc = "Run gf2 debugger" })

-- Terminal binds
vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Escape terminal mode." })
vim.keymap.set("n", "<leader><leader>b", function() vim.opt.makeprg = vim.fn.input("Build command: ") end)
vim.keymap.set("n", "<leader>b", "<CMD>make!<CR>") -- ! prevents auto jumping to first issue in makeprg output.
vim.keymap.set("n", "<leader><leader>r", function() run_command = vim.fn.input("Run command: ") end)
vim.keymap.set("n", "<leader>r",
  function()
    -- Ensure terminal buffer exists.
    local term_buf = get_first_term_buf_id()
    if term_buf == nil then
      vim.cmd.terminal()
      vim.cmd.sleep("50ms") -- Sleep a little bit before use, there appears to be a race condition when starting a terminal.
      vim.cmd("normal! G") -- Move to the end of the terminal so that it scrolls with the output.
      term_buf = vim.api.nvim_get_current_buf()
    end
    vim.fn.chansend(vim.bo[term_buf].channel, run_command .. "\r\n")
  end)
vim.keymap.set("n", "<leader>t",
  function()
    -- Search for existing term buffer and show it.
    local term_buf = get_first_term_buf_id()
    if term_buf then
      vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), term_buf)
    else
      vim.cmd.terminal() -- If terminal buffer doesn't exist create one.
    end
  end,
  { desc = "Go to Terminal." })

-- Run line or highlighted section in lua
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- Move highlighted text up or down with Shift-j/k
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Maintain consistent word deletion in nvim insert mode as other GUI programs,
--vim.keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete work backwards in insert mode. Disable in favour of movement binds as <C-w> can just be used." },
vim.keymap.set("i", "<C-Del>", "<C-o>de", { desc = "Delete word forwards in insert mode." })

vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left while in Insert mode." })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right while in Insert mode." })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up while in Insert mode." })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down while in Insert mode." })

vim.keymap.set("c", "<C-h>", "<Left>", { desc = "Move left while in Command line mode." })
vim.keymap.set("c", "<C-l>", "<Right>", { desc = "Move right while in Command line mode." })
vim.keymap.set("c", "<C-k>", "<Up>", { desc = "Select previous in command history." })
vim.keymap.set("c", "<C-j>", "<Down>", { desc = "Select next in command history." })

-- Telescope bindings
vim.keymap.set("n", "<leader>sf", function() require("telescope.builtin").find_files() end, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", function() require("telescope.builtin").live_grep() end, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sh", function() require("telescope.builtin").help_tags() end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", function() require("telescope.builtin").grep_string() end, { desc = "[S]earch Current [W]ord" })
vim.keymap.set("n", "<leader>sk", function() require("telescope.builtin").keymaps() end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>st", function() require("telescope.builtin").builtin() end, { desc = "[S]earch [T]elescope builtin functions" })
vim.keymap.set("n", "<leader>sd", function() require("telescope.builtin").diagnostics() end, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", function() require("telescope.builtin").resume() end, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>sb", function() require("telescope.builtin").buffers() end, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>s.", function() require("telescope.builtin").oldfiles() end, { desc = "[S]earch Recent Files ('.' for repeat)" })
vim.keymap.set("n", "<leader>su", function() require("telescope.builtin").undo() end, { desc = "[S]earch [U]ndo" })
vim.keymap.set("n", "<leader>/",
  function()
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_ivy {
      winblend = 10,
      previewer = false,
    })
  end,
  { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>sn",
  function() require("telescope.builtin").find_files { cwd = "~/Repos/dotfiles/home/.config/nvim", } end,
  { desc = "[S]earch [N]eovim config" })
vim.keymap.set("n", "<leader>sm",
  function()
    -- For some reason only the first section is searched by default.
    require("telescope.builtin").man_pages { sections = { "ALL" } }
  end,
  { desc = "[S]earch [M]an Pages" })

-- Harpoon binds
vim.keymap.set("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "" })
vim.keymap.set("n", "<leader>h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, { desc = "" })
vim.keymap.set("n", "<C-c>", function() require("harpoon").ui:close_menu() end, { desc = "" })
vim.keymap.set("n", "<C-p>", function() require("harpoon"):list():prev() end, { desc = "Toggle previous & next buffers stored within Harpoon list" })
vim.keymap.set("n", "<C-n>", function() require("harpoon"):list():next() end, { desc = "" })
vim.keymap.set("n", "<C-h>", function() require("harpoon"):list():select(1) end, { desc = "" })
vim.keymap.set("n", "<C-j>", function() require("harpoon"):list():select(2) end, { desc = "" })
vim.keymap.set("n", "<C-k>", function() require("harpoon"):list():select(3) end, { desc = "" })
vim.keymap.set("n", "<C-l>", function() require("harpoon"):list():select(4) end, { desc = "" })
vim.keymap.set("n", "<leader><C-h>", function() require("harpoon"):list():replace_at(1) end, { desc = "" })
vim.keymap.set("n", "<leader><C-j>", function() require("harpoon"):list():replace_at(2) end, { desc = "" })
vim.keymap.set("n", "<leader><C-k>", function() require("harpoon"):list():replace_at(3) end, { desc = "" })
vim.keymap.set("n", "<leader><C-l>", function() require("harpoon"):list():replace_at(4) end, { desc = "" })

-- LSP Keybinds
local lsp_keymaps = {
  { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },
  { "<leader>rn", vim.lsp.buf.rename, desc = "ReName" },
  { '<F2>', vim.lsp.buf.rename, desc = "Rename with windows style binding"},
  { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "ga", vim.lsp.buf.code_action, desc = "Goto Action" },
  { 'gi', vim.lsp.buf.implementation, desc = "Goto Implementation" },
  { 'go', vim.lsp.buf.type_definition, },
  { 'gr', vim.lsp.buf.references, },
  { 'gs', vim.lsp.buf.signature_help, },
  { '<leader>f', function() vim.lsp.buf.format({ async = true }) end, mode = { 'n', 'x' } },
}

local function set_keymaps(keymaps, buffer)
  for _, keymap in ipairs(keymaps) do
    local mode = keymap.mode or 'n'
    local opts = { desc = keymap.desc, buffer = buffer }
    vim.keymap.set(mode, keymap[1], keymap[2], opts)
  end
end

-- Keybinds have to be set after the LSP is initialised.
vim.api.nvim_create_autocmd("LspAttach", { callback = function(event) set_keymaps(lsp_keymaps, event.buf) end })

-- LSP Server Configuration --

local lsp_servers = {
  lua_ls = { settings = { Lua = { diagnostics = { globals = { 'vim' } }, telemetry = { enable = false } } } },
  clangd = { cmd = { "clangd", "--header-insertion=never"}},
  rust_analyzer = {
    settings = {
      cargo = { features = "all" },
      procMacro = { enable = true },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureCaptureHints = { enable = true },
        closureReturnTypeHints = { enable = true },
        expressionAdjustmentHints = { enable = true }
      },
      diagnostics = { enable = true }
    }
  }
}

local lsp_server_names = {}
for server_name, _ in pairs(lsp_servers) do
  table.insert(lsp_server_names, server_name)
end

-- Plugin Setup --

-- Install lazy nvim if it doesn't exist
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "https://github.com/folke/lazy.nvim.git", "--filter=blob:none",
    "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo( { { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Add lazy into the runtime path for neovim so that the lazy can be found.
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup({
  spec = {
    {
      -- "folke/tokyonight.nvim",
      "Mofiqul/dracula.nvim",
      config = function(opts)
        theme = opts.name:match("[^.]+")
        vim.cmd.colorscheme(theme) -- Automatically set theme based on plugin name.

        -- Enable transparency
        vim.cmd('hi Directory guibg=NONE')
        vim.cmd('hi SignColumn guibg=NONE')
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
      end
    },
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons", }, opts = { theme = "dracula" }, },
    { "brenoprata10/nvim-highlight-colors", config = function() require("nvim-highlight-colors").setup({}) end },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "kylechui/nvim-surround", version = "*", config = true }, -- * = stable
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("harpoon"):setup()
      end,
    },
    {
      "kdheepak/lazygit.nvim",
      cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile", },
      config = function() vim.g.lazygit_floating_window_scaling_factor = 1.0 end,
      dependencies = { "nvim-lua/plenary.nvim", },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          modules = {},
          ignore_install = {},
          sync_install = false,
          auto_install = true,
          ensure_installed = { "vim", "vimdoc", "lua", "bash", "c", "cpp", "go", "rust", "python", "markdown", "toml", "json" },
          highlight = { enable = true },
        })
      end
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim", },
      config = function()
        require("telescope").setup({
          defaults = {
            sorting_strategy = "ascending",
            mappings = {
              i = {
                -- TODO: Move these bindings to the top.
                ["<C-k>"] = require("telescope.actions").move_selection_previous,
                ["<C-j>"] = require("telescope.actions").move_selection_next,
                ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
              }
            }
          }
        })
      end
    },
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        "hrsh7th/cmp-nvim-lsp-signature-help",
        'saadparwaiz1/cmp_luasnip',
        'rafamadriz/friendly-snippets',
        { 'L3MON4D3/LuaSnip', config = function() require("luasnip.loaders.from_vscode").lazy_load() end },
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require('luasnip')

        cmp.setup({
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'nvim_lsp_document_symbol' },
            { name = 'buffer' },
          },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          view = { docs = { auto_open = true }},
          -- TODO: Move these bindings.
          mapping = cmp.mapping.preset.insert({
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
              elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
              else fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if luasnip.locally_jumpable(-1) then luasnip.jump(-1)
              else fallback()
              end
            end, { 'i', 's' }),
            ['<C-n>'] = cmp.mapping(function(fallback)
              if cmp.visible() then cmp.select_next_item()
              else fallback()
              end
            end, { 'i', 's' }),
            ['<C-p>'] = cmp.mapping(function(fallback)
              if cmp.visible() then cmp.select_prev_item()
              else fallback()
              end
            end, { 'i', 's' }),
            ['<C-k>'] = cmp.mapping(function(fallback)
              if cmp.visible_docs() then cmp.close_docs()
              elseif cmp.visible() then cmp.open_docs()
              else fallback()
              end
            end, { 'i', 's' }),
          }),
        })
      end
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } }, -- Automatically configure the lua LSP.
        'hrsh7th/nvim-cmp',
      },
      opts = { servers = lsp_servers },
      config = function(_, opts)
        vim.diagnostic.config({
          virtual_text = true, -- Enable inline diagnostics
          signs = {
            active = true,
            text = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN]  = " ",
              [vim.diagnostic.severity.HINT]  = "󰟃 ",
              [vim.diagnostic.severity.INFO]  = " ",
            }
          }
        })

        local capabilities = vim.tbl_deep_extend( "force", {}, vim.lsp.protocol.make_client_capabilities(), require("cmp_nvim_lsp").default_capabilities())

        for server, config in pairs(opts.servers) do
          config.capabilities = capabilities
          vim.lsp.config[server] = config
        end
      end
    },
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = { { "mason-org/mason.nvim", config = true }, "neovim/nvim-lspconfig", },
      opts = { ensure_installed = lsp_server_names, automatic_enable = true, }
    }
  }
})

-- Filetype configurations --

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Save autocmds --

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

-- Neovide configuration --
if vim.g.neovide then
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_opacity = 0.9
  vim.g.neovide_normal_opacity = 0.9
  vim.g.neovide_cursor_animation_length = 0.02
  vim.g.neovide_cursor_trail_size = 0.05

  vim.cmd.colorscheme(theme) -- Fix issue with neovide not setting colours correctly the first time.
end


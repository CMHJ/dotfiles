-- TODO
-- Remove dead code
-- Move keybinds into simple tables at the top
-- Add comment bind with C-/
-- Add binding for simpler file create like 'f' instead of % in netrw
-- Fix shell completion for build and run commands by adding options, something like ui_prompt?
-- Remove desc = ""
-- remove the lazy and priority stuff that doesn't do anything.
-- Setup telescope with harpoon for consistent windows.
-- Do lazy clean to remove unused plugins

-- Set global variables --

local g = vim.g
g.mapleader = " " -- Set leader to spacebar
g.maplocalleader = "\\"

-- netrw file explorer configuration
g.netrw_banner = 0
g.netrw_browse_split = 0
g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size
g.netrw_liststyle = 1 -- ls -l style view
-- g.netrw_liststyle = 3 -- tree view
g.netrw_sizestyle = "h" -- human readable file size

-- Set options --

local opt = vim.opt
opt.winborder = "rounded"
opt.clipboard = "unnamedplus" -- Use system clipboard for everything
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.signcolumn = "yes" -- Just keep sign column on to avoid annoying flicker
opt.swapfile = false -- Remove annoying backup and swap defaults
opt.backup = false
opt.undofile = true
opt.tabstop = 4 -- Default indentation
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.timeout = true -- Timeout
opt.timeoutlen = 250 -- ms
opt.colorcolumn = { "80", "120" } -- Create highlighted columns in editor for line lengths

vim.o.winborder = "rounded"

-- Custom Functions --

-- Set default run command to "build/<dir>", assumes that output binary is same name as directory.
local run_command = "./build/" .. vim.fs.basename(vim.fn.getcwd())
local floating_win = {
  buf = -1,
  win = -1
}

local function create_floating_win(opts)
  opts = opts or { buf = -1 }

  local height = opts.height or math.min(math.floor(vim.o.lines * 0.25), 15)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer.
  end

  local win = vim.api.nvim_open_win(buf, true, { split = "below", height = height })

  return { buf = buf, win = win }
end

local function terminal_toggle(args)
  args = args or {}
  local show = args.show or false

  if vim.api.nvim_win_is_valid(floating_win.win) == false then
    floating_win = create_floating_win { buf = floating_win.buf }
    if vim.bo[floating_win.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
      vim.cmd.sleep("50ms") -- Sleep a little bit before use, there appears to be race conditions.
      vim.cmd("normal! G") -- Move to the end of the terminal so that it scrolls with the output.
    end
  elseif show then
    -- Do nothing as window is already open.
  else
    vim.api.nvim_win_hide(floating_win.win)
  end
end

-- Keybinds --

local general_keymaps = {
  { "<leader>q", "<cmd>qa<CR>", desc = "Quit all buffers." },
  { "Q", "<nop>", desc = "Disable Ex mode, if you know you know. Doesn't seem to have this behaviour in nvim but disable anyway." },

  -- netrw file explorer binds --
  { "<leader>pv", vim.cmd.Ex, desc = "Open netrw file explorer." },
  -- { "<leader>pv", vim.cmd.Lexplore, mode = "n", desc = "Open small file explorer to the side." },

  -- Quickfix list bindings --
  { "]q", "<cmd>cnext<CR>", desc = "" },
  { "[q", "<cmd>cprev<CR>", desc = "" },
  -- copen - to open quickfix list, because 'c' is for quickfix... it makes sense
  -- clist - to temporarily show the quickfix list
  -- cdo <cmd> - apply command to all items in the quickfix list like a sub cmd

  -- Keep screen centred when moving around
  { "<C-d>", "<C-d>zz", desc = "" },
  { "<C-u>", "<C-u>zz", desc = "" },
  { "n", "nzzzv", desc = "" },
  { "N", "Nzzzv", desc = "" },
  { "<C-i>", "<C-i>zz", desc = "Jump forward and center." },
  { "<C-o>", "<C-o>zz", desc = "Jump back and center." },
  { "*", "*zz", desc = "Search word under cursor and center." },
  { "#", "#zz", desc = "Search word under cursor backwards and center." },

  -- Use ctrl keys to move between panes
  -- vim.keymap.set("n", "<C-j>", "<C-w>j")
  -- vim.keymap.set("n", "<C-k>", "<C-w>k")
  -- vim.keymap.set("n", "<C-h>", "<C-w>h")
  -- vim.keymap.set("n", "<C-l>", "<C-w>l")

  -- Resize current window using -/_ and =/+ keys
  { "+", [[<cmd>horizontal resize +2<cr>]], desc = "" },
  { "_", [[<cmd>horizontal resize -2<cr>]], desc = "" },
  -- { "+", [[<cmd>horizontal resize +5<cr>]], desc = "" },
  -- { "_", [[<cmd>vertical resize -5<cr>]], desc = "" },
  -- TODO: Add fullscreen toggle

  {
    "<leader>l",
    function()
      vim.wo.number = not vim.wo.number
      vim.wo.relativenumber = not vim.wo.relativenumber
    end,
    desc = "Toggle relative line numbering, wo for window option as opt sets the option that only works on first load."
  },

  { "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>]], desc = "Find and replace current word under cursor." },
  { "<leader>s", [[y:%s/<C-r>"/<C-r>"/g<Left><Left>]], mode = "x", desc = "Find and replace currently highlighted text." },

  -- Yank and Delete into the system clipboard
  { "<leader>y", [["+y]], mode = { "n", "v" }, desc = "" },
  --vim.keymap.set("n", "<leader>Y", [["+Y]])

  { "<leader>p", [["_dP]], mode = "x", desc = "Send highlighted text to null register and paste from default register." },
  { "<leader>d", [["_d]], mode = { "n", "v" }, desc = "Set null register." },

  { "<leader><leader>x", ":source %<CR>", desc = "Source current file." },

  -- Terminal binds --
  { "<leader><C-c>", "<C-\\><C-n>", mode = "t", desc = "Escape terminal mode." },
  { "<leader><leader>b", function() vim.opt.makeprg = vim.fn.input("Build command: ") end },
  { "<leader>b", "<cmd>make<CR>" },
  { "<leader><leader>r", function() run_command = vim.fn.input("Run command: ") end },
  { "<leader>r",
    function()
      terminal_toggle({ show = true })
      local term_job_id = vim.b[floating_win.buf].terminal_job_id
      vim.fn.chansend(term_job_id, run_command .. "\r\n")
    end
  },
  { "<leader>t", terminal_toggle, desc = "Toggle terminal." },

  -- Run line or highlighted section in lua
  { "<leader>x", ":.lua<CR>" },
  { "<leader>x", ":lua<CR>", mode = "v" },

  -- Move highlighted text up or down with Shift-j/k
  { "J", ":m '>+1<CR>gv=gv", mode = "v" },
  { "K", ":m '<-2<CR>gv=gv", mode = "v" },

  -- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
  { "<C-c>", "<Esc>", mode = "i" },

  -- Maintain consistent word deletion in nvim insert mode as other GUI programs,
  -- e.g. Ctrl-Backspace deletes word backwards
  -- and Ctrl-Delete deletes word forwards.
  -- { "<C-h>", "<C-w>", mode = "i", desc = "Disable in favour of movement binds." },
  { "<C-Del>", "<C-o>de", mode = "i" },

  { "<C-l>", "<Right>", mode = "i", desc = "Move right while in Insert mode." },
  { "<C-h>", "<Left>", mode = "i", desc = "Move left while in Insert mode." },

  { "<C-l>", "<Right>", mode = "c", desc = "Move right while in Command line mode." },
  { "<C-h>", "<Left>", mode = "c", desc = "Move left while in Command line mode." },

  { "<C-k>", "<Up>", mode = "c", desc = "Select previous in command history." },
  { "<C-j>", "<Down>", mode = "c", desc = "Select next in command history." },
}

local plugin_keymaps = {
  -- Telescope bindings --
  { "<leader>sf", function() require("telescope.builtin").find_files() end, desc = "[S]earch [F]iles" },
  { "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "[S]earch by [G]rep" },
  { "<leader>sh", function() require("telescope.builtin").help_tags() end, desc = "[S]earch [H]elp" },
  { "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "[S]earch Current [W]ord" },
  { "<leader>sk", function() require("telescope.builtin").keymaps() end, desc = "[S]earch [K]eymaps" },
  { "<leader>st", function() require("telescope.builtin").builtin() end, desc = "[S]earch [T]elescope builtin functions" },
  { "<leader>sd", function() require("telescope.builtin").diagnostics() end, desc = "[S]earch [D]iagnostics" },
  { "<leader>sr", function() require("telescope.builtin").resume() end, desc = "[S]earch [R]esume" },
  { "<leader>sb", function() require("telescope.builtin").buffers() end, desc = "[S]earch [B]uffers" },
  { "<leader>s.", function() require("telescope.builtin").oldfiles() end, desc = "[S]earch Recent Files ('.' for repeat)" },
  { "<leader>su", function() require("telescope.builtin").undo() end, desc = "[S]earch [U]ndo" },
  {
    "<leader>/",
    function()
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_ivy {
        winblend = 10,
        previewer = false,
      })
    end,
    desc = "[/] Fuzzily search in current buffer"
  },
  {
    "<leader>sn",
    function() require("telescope.builtin").find_files { cwd = "~/Repos/dotfiles/home/.config/nvim", } end,
    desc = "[S]earch [N]eovim config"
  },
  {
    "<leader>sm",
    function()
      -- For some reason only the first section is searched by default.
      require("telescope.builtin").man_pages { sections = { "ALL" } }
    end,
    desc = "[S]earch [M]an Pages"
  },

  -- Harpoon binds --
  { "<leader>a", function() require("harpoon"):list():add() end, desc = "" },
  { "<leader>h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "" },
  { "<C-c>", function() require("harpoon").ui:close_menu() end, desc = "" },
  { "<C-p>", function() require("harpoon"):list():prev() end, desc = "Toggle previous & next buffers stored within Harpoon list" },
  { "<C-n>", function() require("harpoon"):list():next() end, desc = "" },
  { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "" },
  { "<C-j>", function() require("harpoon"):list():select(2) end, desc = "" },
  { "<C-k>", function() require("harpoon"):list():select(3) end, desc = "" },
  { "<C-l>", function() require("harpoon"):list():select(4) end, desc = "" },
  { "<leader><C-h>", function() require("harpoon"):list():replace_at(1) end, desc = "" },
  { "<leader><C-j>", function() require("harpoon"):list():replace_at(2) end, desc = "" },
  { "<leader><C-k>", function() require("harpoon"):list():replace_at(3) end, desc = "" },
  { "<leader><C-l>", function() require("harpoon"):list():replace_at(4) end, desc = "" },
}

local lsp_keymaps = {
  -- diagnostics
  -- TODO: Fix this
  -- • *vim.diagnostic.goto_next()* Use |vim.diagnostic.jump()| with `{count=1, float=true}` instead.
  -- • *vim.diagnostic.goto_prev()* Use |vim.diagnostic.jump()| with `{count=-1, float=true}` instead.
  { "<leader>dn", function() vim.diagnostic.jump({ count=1, float=true, severity = vim.diagnostic.severity.ERROR }) end, desc = "Go to next error" },
  { "<leader>dp", function() vim.diagnostic.jump({ count=-1, float=true, severity = vim.diagnostic.severity.ERROR }) end, desc = "Go to previous error" },
  { "<leader>do", vim.diagnostic.open_float, desc = "Open floating diagnostic message" },

  -- lsp
  { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "ga", vim.lsp.buf.code_action, desc = "Goto Action" },
  { "<leader>rn", vim.lsp.buf.rename, desc = "ReName" },
  { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },
}

-- Key bindings helper
local function set_keymaps(keymaps, buffer)
  for _, keymap in ipairs(keymaps) do
    local mode = keymap.mode or 'n'
    local opts = { desc = keymap.desc, buffer = buffer }
    vim.keymap.set(mode, keymap[1], keymap[2], opts)
  end
end

set_keymaps(general_keymaps)
set_keymaps(plugin_keymaps)

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
-- Setup lazy.nvim plugins
require("lazy").setup({
  -- change_detection = { notify = false },
  spec = {
    -- "folke/tokyonight.nvim"
    {
      "Mofiqul/dracula.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("dracula")
        -- Enable transparency
        vim.cmd('hi Directory guibg=NONE')
        vim.cmd('hi SignColumn guibg=NONE')
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
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
    { "tpope/vim-fugitive" },
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
                ["<C-k>"] = require("telescope.actions").move_selection_previous,
                ["<C-j>"] = require("telescope.actions").move_selection_next,
                ["<C-q>"] = require("telescope.actions").send_selected_to_qflist +
                    require("telescope.actions").open_qflist,
              }
            }
          }
        })
      end
    },

    -- {
    --   "saghen/blink.cmp",
    --   dependencies = "rafamadriz/friendly-snippets",
    --   version = "v1.*",
    --   opts = {
    --     keymap = { preset = "default" },
    --     appearance = {
    --       nerd_font_variant = "normal"
    --     },
    --     -- Disable bracket insertion, as this seems to break the signature showing after selection.
    --     completion = { accept = { auto_brackets = { enabled = false } } },
    --     signature = {
    --       enabled = true, -- Show function signatures
    --       window = { show_documentation = true } -- Also show documentation
    --     }
    --   },
    -- },

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
          mapping = cmp.mapping.preset.insert({
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<C-n>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<C-p>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<C-k>'] = cmp.mapping(function(fallback)
              if cmp.visible_docs() then
                cmp.close_docs()
              elseif cmp.visible() then
                cmp.open_docs()
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),
        })
      end
    },

    {
      "neovim/nvim-lspconfig",
      dependencies = {
        -- Automatically configure the lua LSP.
        { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },
        'hrsh7th/nvim-cmp',
        -- 'saghen/blink.cmp',
      },
      opts = {
        servers = {
          lua_ls = {},
          clangd = { init_options = { fallbackFlags = { '--std=c99' } } },
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
      },
      config = function(_, opts)
        vim.diagnostic.config({ virtual_text = true, }) -- Enable inline diagnostics

        local function on_attach(_, bufnr)
        end

        local capabilities = vim.tbl_deep_extend(
          "force",
          {},
          vim.lsp.protocol.make_client_capabilities(),
          require("cmp_nvim_lsp").default_capabilities()
          -- require('blink.cmp').get_lsp_capabilities()
        )

        for server, config in pairs(opts.servers) do
          config.on_attach = on_attach
          config.capabilities = capabilities
          vim.lsp.config[server] = config
        end
      end
    },
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = {
        { "mason-org/mason.nvim", config = true },
        "neovim/nvim-lspconfig",
      },
      opts = {
        ensure_installed = { "lua_ls", "clangd", "rust_analyzer" },
        automatic_enable = true,
      },
    },

  },
})

-- vim.lsp.config('*', {
-- root_markers = { '.git' },
-- })
-- vim.lsp.config["lua_ls"] = {
-- cmd = { "lua-language-server" },
-- root_markers = { ".git", ".luarc.json" },
-- filetypes = { "lua" },
-- settings = {
-- Lua = {
-- runtime = { version = 'LuaJIT' },
-- diagnostics = { globals = { 'vim' } },
-- workspace = {
-- checkThirdParty = false,
-- library = vim.api.nvim_get_runtime_file('', true),
-- },
-- telemetry = { enable = false },
-- },
-- },
-- }
-- vim.lsp.enable("lua_ls")
--
-- vim.api.nvim_create_autocmd('LspAttach', {
-- callback = function(ev)
-- local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- if client:supports_method('textDocument/completion') then
-- vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
-- end
-- end,
-- })
--
-- vim.cmd("set completeopt+=noselect")
-- vim.o.winborder = "rounded"

-- vim.lsp.config('*', {
-- root_markers = { '.git' },
-- })
--
-- vim.diagnostic.config({
-- virtual_text = true,
-- severity_sort = true,
-- float = {
-- style = 'minimal',
-- border = 'rounded',
-- source = 'if_many',
-- header = '',
-- prefix = '',
-- },
-- signs = {
-- text = {
-- [vim.diagnostic.severity.ERROR] = '✘',
-- [vim.diagnostic.severity.WARN] = '▲',
-- [vim.diagnostic.severity.HINT] = '⚑',
-- [vim.diagnostic.severity.INFO] = '»',
-- },
-- },
-- })

-- -- put early in lsp.lua
-- local orig = vim.lsp.util.open_floating_preview
-- ---@diagnostic disable-next-line: duplicate-set-field
-- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
-- opts = opts or {}
-- opts.border = opts.border or 'rounded'
-- opts.max_width = opts.max_width or 80
-- opts.max_height = opts.max_height or 24
-- opts.wrap = opts.wrap ~= false
-- return orig(contents, syntax, opts, ...)
-- end

-- 4) Per-buffer behavior on LSP attach (keymaps, auto-format, completion)
-- See :help LspAttach for the recommended pattern
-- vim.api.nvim_create_autocmd('LspAttach', {
-- group = vim.api.nvim_create_augroup('my.lsp', {}),
-- callback = function(args)
-- local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
-- local buf = args.buf
-- local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end
--
-- -- Keymaps (use builtin LSP buffer functions)
-- map('n', 'K', vim.lsp.buf.hover)
-- map('n', 'gd', vim.lsp.buf.definition)
-- map('n', 'gD', vim.lsp.buf.declaration)
-- map('n', 'gi', vim.lsp.buf.implementation)
-- map('n', 'go', vim.lsp.buf.type_definition)
-- map('n', 'gr', vim.lsp.buf.references)
-- map('n', 'gs', vim.lsp.buf.signature_help)
-- map('n', 'gl', vim.diagnostic.open_float)
-- map('n', '<F2>', vim.lsp.buf.rename)
-- map({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end)
-- map('n', '<F4>', vim.lsp.buf.code_action)
--
-- -- Put near your LSP on_attach
-- local excluded_filetypes = { php = true }
--
-- -- Auto-format on save (only if server can't do WillSaveWaitUntil)
-- if not client:supports_method('textDocument/willSaveWaitUntil')
-- and client:supports_method('textDocument/formatting')
-- and not excluded_filetypes[vim.bo[buf].filetype]
-- then
-- vim.api.nvim_create_autocmd('BufWritePre', {
-- group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
-- buffer = buf,
-- callback = function()
-- vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 1000 })
-- end,
-- })
-- end
-- end,
-- })

-- 5) Define the Lua language server config (no mason/lspconfig)
-- See :help lsp-new-config and :help vim.lsp.config()
-- local caps = require('blink.cmp').get_lsp_capabilities()
-- vim.lsp.config['luals'] = {
-- cmd = { 'lua-language-server' },
-- filetypes = { 'lua' },
-- root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
-- capabilities = caps,
-- settings = {
-- Lua = {
-- runtime = { version = 'LuaJIT' },
-- diagnostics = { globals = { 'vim' } },
-- workspace = {
-- checkThirdParty = false,
-- library = vim.api.nvim_get_runtime_file('', true),
-- },
-- telemetry = { enable = false },
-- },
-- },
-- }
--
-- vim.lsp.enable('luals')

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


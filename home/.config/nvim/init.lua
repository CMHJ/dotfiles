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

local g = vim.g
g.mapleader = " " -- Set leader to spacebar.
g.maplocalleader = "\\"

-- netrw file explorer configuration
g.netrw_banner = 0
g.netrw_browse_split = 0
g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size.
g.netrw_liststyle = 1 -- ls -l style view
-- g.netrw_liststyle = 3 -- tree view
g.netrw_sizestyle = "h" -- human readable file size

-- Set options --

local opt = vim.opt
opt.winborder = "rounded"
opt.clipboard = "unnamedplus" -- Use system clipboard for everything.
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
opt.signcolumn = "yes" -- Just keep sign column on to avoid annoying flicker.
opt.autoread = true
opt.swapfile = false -- Remove annoying backup and swap defaults.
opt.backup = false
opt.undofile = true
opt.tabstop = 4 -- Default indentation.
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.timeout = true -- Timeout
opt.timeoutlen = 250 -- ms
opt.colorcolumn = { "80", "120" } -- Create highlighted columns in editor for line lengths.

vim.o.winborder = "rounded"

-- Disable comment continuation on newline.
vim.api.nvim_create_autocmd("FileType", { pattern = "*", callback = function() vim.opt_local.formatoptions:remove({ 'r', 'o' }) end })

-- Automatically jump to last position in file and unfold lines when opened again.
vim.api.nvim_create_autocmd("BufReadPost", { pattern = "*", command = 'silent! normal! g`"zv' })

-- Custom Functions --

-- If the first argument is a directory, cd to that directory
local function is_dir(path) local stat = (vim.uv or vim.loop).fs_stat(path) return (stat ~= nil) and stat.type == "directory" end
if vim.fn.argc() > 0 and is_dir(vim.fn.argv(0)) then vim.cmd.cd(vim.fn.argv(0)) end

-- Set default run command to build.sh or "build/<dir>", assumes that output binary is same name as directory.
-- TODO(CMHJ): Revert this, this is a run command not a build command.
local run_command = nil
if vim.fn.executable("./build.sh") == 1 then print("Hello there") run_command = "./build.sh" else run_command = "./build/" .. vim.fs.basename(vim.fn.getcwd()) end

local floating_win = { buf = -1, win = -1 }

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
    floating_win = create_floating_win({ buf = floating_win.buf })
    if vim.bo[floating_win.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
      vim.cmd.sleep("50ms") -- Sleep a little bit before use, there appears to be race conditions.
      vim.cmd("normal! G") -- Move to the end of the terminal so that it scrolls with the output.
      vim.cmd("wincmd k") -- Move back into window above.
    end
  elseif show then
    -- Do nothing as window is already open.
  else
    -- Handle case where terminal was closed but window wasn't and user attempts to open another one.
    local buf = vim.api.nvim_win_get_buf(floating_win.win)
    if vim.bo[buf].buftype ~= "terminal" then
      floating_win = { buf = -1, win = -1 } -- Reset state as it is wrong.
      terminal_toggle()
    else
      -- Otherwise hide terminal window normally.
      vim.api.nvim_win_hide(floating_win.win)
    end
  end
end

local function get_first_term_buf_id()
end

local function get_first_term_job_id()
end

-- Keybinds --

local general_keymaps = {
  -- Keep Esc and C-c behaviour consistent, e.g. when finishing a multiline edit
  { "<C-c>", "<Esc>", mode = "i" },

  { "<leader>w", "<CMD>wa<CR>", desc = "Save all buffers." },
  { "<leader>wq", "<CMD>wa<CR><CMD>qa<CR>", desc = "Save and quit all buffers." },
  { "Q", "<nop>", desc = "Disable Ex mode, if you know you know. Doesn't seem to have this behaviour in nvim but disable anyway." },

  -- netrw file explorer binds --
  { "<leader>pv", vim.cmd.Ex, desc = "Open netrw file explorer." },
  -- { "<leader>pv", vim.cmd.Lexplore, mode = "n", desc = "Open small file explorer to the side." },

  -- Quickfix list bindings --
  { "<leader>q",
    function()
      local quickfix_list_open = vim.fn.getqflist({winid = 0}).winid ~= 0
      if quickfix_list_open then vim.cmd("cclose") else vim.cmd("copen") end
    end,
    desc = "Toggle Quickfix list."
  },
  { "]q", "<CMD>cnext<CR>", desc = "" },
  { "[q", "<CMD>cprev<CR>", desc = "" },
  -- copen - to open quickfix list, because 'c' is for quickfix... it makes sense
  -- clist - to temporarily show the quickfix list
  -- cdo <CMD> - apply command to all items in the quickfix list like a sub cmd

  -- Diagnostics
  { "<leader>dn", function() vim.diagnostic.jump({ count=1, float=true, severity = vim.diagnostic.severity.ERROR }) end, desc = "Go to next error" },
  { "<leader>dp", function() vim.diagnostic.jump({ count=-1, float=true, severity = vim.diagnostic.severity.ERROR }) end, desc = "Go to previous error" },
  { "<leader>do", vim.diagnostic.open_float, desc = "Open floating diagnostic message" },

  -- Keep screen centred when moving around
  { "<C-d>", "<C-d>zz", desc = "" },
  { "<C-u>", "<C-u>zz", desc = "" },
  { "n", "nzzzv", desc = "" },
  { "N", "Nzzzv", desc = "" },
  { "<C-i>", "<C-i>zz", desc = "Jump forward and center." },
  { "<C-o>", "<C-o>zz", desc = "Jump back and center." },
  { "*", "*zz", desc = "Search word under cursor and center." },
  { "#", "#zz", desc = "Search word under cursor backwards and center." },

  { "]b", "<CMD>bnext<CR>", mode = "n", desc = "Split horizontally." },
  { "[b", "<CMD>bprev<CR>", mode = "n", desc = "Split vertically." },
  { "<leader>g", "<CMD>split<CR>", mode = "n", desc = "Split horizontally." },
  { "<leader>v", "<CMD>vsplit<CR>", mode = "n", desc = "Split vertically." },

  -- Resize current window using -/_ and =/+ keys
  { "<Up>", [[<CMD>horizontal resize -2<CR>]], desc = "" },
  { "<Down>", [[<CMD>horizontal resize +2<CR>]], desc = "" },
  { "<Left>", [[<CMD>vertical resize -5<CR>]], desc = "" },
  { "<Right>", [[<CMD>vertical resize +5<CR>]], desc = "" },
  -- TODO: Add fullscreen toggle

  {
    "<leader>l",
    function()
      vim.wo.number = not vim.wo.number
      vim.wo.relativenumber = not vim.wo.relativenumber
    end,
    desc = "Toggle relative line numbering, wo for window option as opt sets the option that only works on first load."
  },

  { "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left>]], desc = "Find and replace current word under cursor." },
  { "<leader>s", [[y:%s/<C-r>"/<C-r>"/gc<Left><Left>]], mode = "x", desc = "Find and replace currently highlighted text." },

  -- Yank and Delete into the system clipboard
  { "<leader>y", [["+y]], mode = { "n", "v" }, desc = "" },
  { "<leader>p", [["+p]], mode = { "n", "v" }, desc = "" },
  { "<leader>d", [["_d]], mode = { "n", "v" }, desc = "Set null register." },
  { "<leader>p", [["_dP]], mode = "x", desc = "Paste from system clipboard over highlighted text and send overwritten text to null register." },
  { "<C-v>", [[<C-r>+]], mode = { "i", "c" }, desc = "Paste from system clipboard." },

  { "<leader><leader>x", "<CMD>source %<CR>", desc = "Source current file." },

  { "<leader>lg", "<CMD>LazyGit<CR>", desc = "LazyGit" },
  { "<leader>db", function() vim.cmd("silent !gf2 " .. run_command .. " &") end, desc = "Run gf2 debugger" },

  -- Terminal binds
  { "<C-o>", "<C-\\><C-n>", mode = "t", desc = "Escape terminal mode." },
  { "<leader><leader>b", function() vim.opt.makeprg = vim.fn.input("Build command: ") end },
  { "<leader>b", "<CMD>make!<CR>" }, -- ! prevents auto jumping to first issue in makeprg output.
  { "<leader><leader>r", function() run_command = vim.fn.input("Run command: ") end },
  { "<leader>r",
    function()
      terminal_toggle({ show = true })
      local term_job_id = vim.b[floating_win.buf].terminal_job_id
      vim.fn.chansend(term_job_id, run_command .. "\r\n")
    end
  },
  -- { "<leader>t", terminal_toggle, desc = "Toggle terminal." },
  { "<leader>t",
    function()
      -- Search for existing term buffer and show it.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
          if vim.bo[buf].buftype == "terminal" then
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            return
          end
        end
      end
      -- If terminal buffer doesn't exist create one.
      vim.cmd("term")
    end,
    desc = "Go to Terminal."
  },

  -- Run line or highlighted section in lua
  { "<leader>x", ":.lua<CR>" },
  { "<leader>x", ":lua<CR>", mode = "v" },

  -- Move highlighted text up or down with Shift-j/k
  { "J", ":m '>+1<CR>gv=gv", mode = "v" },
  { "K", ":m '<-2<CR>gv=gv", mode = "v" },

  -- Maintain consistent word deletion in nvim insert mode as other GUI programs,
  -- e.g. Ctrl-Backspace deletes word backwards and Ctrl-Delete deletes word forwards.
  -- { "<C-h>", "<C-w>", mode = "i", desc = "Disable in favour of movement binds as <C-w> can just be used." },
  { "<C-Del>", "<C-o>de", mode = "i" },

  { "<C-h>", "<Left>", mode = "i", desc = "Move left while in Insert mode." },
  { "<C-l>", "<Right>", mode = "i", desc = "Move right while in Insert mode." },
  { "<C-k>", "<Up>", mode = "i", desc = "Move up while in Insert mode." },
  { "<C-j>", "<Down>", mode = "i", desc = "Move down while in Insert mode." },

  { "<C-h>", "<Left>", mode = "c", desc = "Move left while in Command line mode." },
  { "<C-l>", "<Right>", mode = "c", desc = "Move right while in Command line mode." },
  { "<C-k>", "<Up>", mode = "c", desc = "Select previous in command history." },
  { "<C-j>", "<Down>", mode = "c", desc = "Select next in command history." },
}

local plugin_keymaps = {
  -- Telescope bindings
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

  -- Harpoon binds
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


-- TODO
-- - Remove dead code
-- - Move keybinds into simple tables at the top
-- - Add comment bind with C-/
-- - Add binding for simpler file create like 'f' instead of % in netrw

-- Set global variables --

local g = vim.g
g.mapleader = " " -- Set leader to spacebar
g.maplocalleader = " "

-- netrw file explorer configuration
g.netrw_banner = 0
g.netrw_browse_split = 0
g.netrw_winsize = 25 -- When using netrw with Lexplore set the window size
g.netrw_liststyle = 1 -- ls -l style view
-- g.netrw_liststyle = 3 -- tree view
g.netrw_sizestyle = "h" -- human readable file size

-- Set options --

local opt = vim.opt
opt.clipboard="unnamedplus" -- Use system clipboard for everything
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.signcolumn = "yes"-- Just keep sign column on to avoid annoying flicker
opt.swapfile = false -- Remove annoying backup and swap defaults
opt.backup = false
opt.undofile = true
opt.tabstop = 4 -- Default indentation
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.timeout = true -- Timeout
opt.timeoutlen = 400 -- ms
opt.colorcolumn = {"80", "120"} -- Create highlighted columns in editor for line lengths

-- Custom Functions --

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

  -- TODO: Add option to leave terminal open in the case you want to check that it's open.
  -- Maybe factor out the function above as a check?
  -- TODO: Make this function toggle whether the terminal is open or not.

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

-- Keybinds --

local general_keymaps = {
  { "Q",          "<nop>",    desc = "Disable Ex mode, if you know you know. Doesn't seem to have this behaviour in nvim but disable anyway." },

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
  { "<leader>s", [[y:%s/<C-r>"/<C-r>"/g<Left><Left>]], desc = "Find and replace currently highlighted text." },

  -- Yank and Delete into the system clipboard
  { "<leader>y", [["+y]], mode = {"n", "v"}, desc = "" },
  --vim.keymap.set("n", "<leader>Y", [["+Y]])

  { "<leader>p", [["_dP]], mode = "x", desc = "Send highlighted text to null register and paste from default register." },
  { "<leader>d", [["_d]], mode = {"n", "v"}, desc = "Set null register." },

  { "<leader><leader>x", ":source %<CR>", desc = "Source current file." },

  -- Terminal binds --
  { "<leader><C-c>", "<C-\\><C-n>", mode = "t", desc = "Escape terminal mode." },
  { "<leader><leader>b", function() vim.opt.makeprg = vim.fn.input("!Build command: ") end },
  { "<leader>b", "<cmd>make<CR>" },
  { "<leader><leader>r", function() run_command = vim.fn.input("!Run command: ") end },
  { "<leader>r",
    function()
      term_ensure_open()
      local term_job_id = vim.b[term_buffer_id].terminal_job_id
      vim.fn.chansend(term_job_id, run_command .. "\n")
    end
  },
  { "<leader>t", function() term_ensure_open() end, desc = "Toggle terminal at the bottom." },

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
  { "<C-h>", "<Left>" , mode = "i", desc = "Move left while in Insert mode." },

  { "<C-l>", "<Right>", mode = "c", desc = "Move right while in Command line mode." },
  { "<C-h>", "<Left>" , mode = "c", desc = "Move left while in Command line mode."},

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
  { "<leader>sb", function() require("telescope.builtin").buffers() end, desc = "[S]earch [B]uffers"},
  { "<leader>s.", function() require("telescope.builtin").oldfiles() end, desc = "[S]earch Recent Files ('.' for repeat)" },
  { "<leader>su", function() require("telescope.builtin").undo() end, desc = "[S]earch [U]ndo" },
  {
    "<leader>/",
    function()
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_ivy {
        winblend = 10,
        previewer = false,
      })
    end, desc = "[/] Fuzzily search in current buffer"
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
  { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "" },
  { "<C-j>", function() require("harpoon"):list():select(2) end, desc = "" },
  { "<C-k>", function() require("harpoon"):list():select(3) end, desc = "" },
  { "<C-l>", function() require("harpoon"):list():select(4) end, desc = "" },
  { "<C-p>", function() require("harpoon"):list():prev() end, desc = "Toggle previous & next buffers stored within Harpoon list" },
  { "<C-n>", function() require("harpoon"):list():next() end, desc = "" },
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
  local out = vim.fn.system({ "git", "clone", "https://github.com/folke/lazy.nvim.git", "--filter=blob:none", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Add lazy into the runtime path for neovim so that the lazy can be found.
vim.opt.runtimepath:prepend(lazypath)
-- Setup lazy.nvim plugins
require("lazy").setup({
  spec = {
    -- Colourschemes
    {
      -- "folke/tokyonight.nvim"
      "Mofiqul/dracula.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("dracula")
      end
    },

    -- Tree-sitter configuration
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup {
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

    {
      "kylechui/nvim-surround",
      version = "*", -- * = stable
      config = true
    },

    -- Harpoon
    {
	    "ThePrimeagen/harpoon",
	    branch = "harpoon2",
	    dependencies = { "nvim-lua/plenary.nvim" },
      config = true,
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


        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = { 'lua_ls', 'clangd' }
        for _, lsp in pairs(servers) do
          vim.lsp.enable(lsp)
          vim.lsp.config(lsp, { on_attach = on_attach })
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

-- Make background transparent
-- vim.cmd([[
--     highlight Normal guibg=none
--     highlight NonText guibg=none
--     highlight Normal ctermbg=none
--     highlight NonText ctermbg=none
-- ]])

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


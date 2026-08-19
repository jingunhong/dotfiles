-- Minimal config derived from kickstart.nvim (vim.pack era).
-- Scope: review agent-produced diffs, occasional manual edits.
-- Plugins: colorscheme, gitsigns, oil, fzf-lua, lspconfig+mason, treesitter.

-- ============================================================
-- Options
-- ============================================================
vim.loader.enable()

-- Must happen before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Minimal statusline; no statusline plugin
vim.o.statusline = ' %f %m%r%=%{&filetype} %l:%c '

-- Files are routinely edited by an agent in another tmux pane; pick up those
-- changes automatically when focus returns (needs `focus-events on` in tmux).
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  desc = 'Reload files changed outside of Neovim',
  group = vim.api.nvim_create_augroup('autoread-checktime', { clear = true }),
  callback = function()
    if vim.o.buftype == '' then vim.cmd 'checktime' end
  end,
})

-- ============================================================
-- Keymaps & autocmds
-- ============================================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  virtual_text = true,
}
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ============================================================
-- Plugins (vim.pack, Neovim's built-in plugin manager)
-- ============================================================
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- Build hook: nvim-treesitter needs :TSUpdate after install/update
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end
    if ev.data.spec.name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

vim.pack.add {
  gh 'folke/tokyonight.nvim',
  gh 'lewis6991/gitsigns.nvim',
  gh 'stevearc/oil.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  gh 'nvim-tree/nvim-tree.lua',
  gh 'ibhagwan/fzf-lua',
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
}

vim.cmd.colorscheme 'tokyonight-night'

require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
}
vim.keymap.set('n', ']c', '<cmd>Gitsigns next_hunk<CR>', { desc = 'Next git hunk' })
vim.keymap.set('n', '[c', '<cmd>Gitsigns prev_hunk<CR>', { desc = 'Previous git hunk' })
vim.keymap.set('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>', { desc = 'Preview git [H]unk' })

-- File browsing: edit the filesystem like a buffer
require('oil').setup()
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })

-- File tree side panel; oil keeps ownership of directory buffers
require('nvim-tree').setup {
  hijack_netrw = false,
  view = { width = 32 },
}
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>', { desc = 'Toggle file [E]xplorer' })

-- ============================================================
-- Fuzzy finding (fzf-lua)
-- ============================================================
local fzf = require 'fzf-lua'
fzf.setup {}
fzf.register_ui_select()

vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf, { desc = '[/] Fuzzily search in current buffer' })

-- ============================================================
-- LSP
-- ============================================================
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('grd', fzf.lsp_definitions, '[G]oto [D]efinition')
    map('grr', fzf.lsp_references, '[G]oto [R]eferences')
    map('gri', fzf.lsp_implementations, '[G]oto [I]mplementation')
    map('grt', fzf.lsp_typedefs, '[G]oto [T]ype Definition')
    map('gO', fzf.lsp_document_symbols, 'Open Document Symbols')
    map('gW', fzf.lsp_live_workspace_symbols, 'Open Workspace Symbols')
    map('<leader>f', function() vim.lsp.buf.format { async = true } end, '[F]ormat buffer')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client then
      -- basedpyright owns hover for Python; ruff only lints/formats
      if client.name == 'ruff' then client.server_capabilities.hoverProvider = false end

      -- Built-in completion; no completion plugin needed
      if client:supports_method('textDocument/completion', event.buf) then
        vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      end
    end
  end,
})

-- mason installs server binaries into ~/.local/share (no root needed)
require('mason').setup {}
require('mason-tool-installer').setup {
  ensure_installed = {
    'clangd', -- C++; expects compile_commands.json in the project root
    'basedpyright',
    'ruff',
  },
}

-- Server definitions come from nvim-lspconfig's `lsp/` directory; enable via
-- the core API (the old require('lspconfig').setup{} framework is deprecated).
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      -- ruff handles import organization
      disableOrganizeImports = true,
    },
  },
})

vim.lsp.enable { 'clangd', 'basedpyright', 'ruff' }

-- ============================================================
-- Treesitter
-- ============================================================
local parsers = { 'bash', 'c', 'cpp', 'diff', 'json', 'lua', 'markdown', 'markdown_inline', 'python', 'query', 'toml', 'vim', 'vimdoc', 'yaml' }
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end
    if not vim.tbl_contains(require('nvim-treesitter').get_installed 'parsers', language) then return end
    if not vim.treesitter.language.add(language) then return end
    vim.treesitter.start(args.buf, language)
    if vim.treesitter.query.get(language, 'indents') then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et

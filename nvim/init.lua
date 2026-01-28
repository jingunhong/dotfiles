local opt = vim.opt

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

opt.clipboard = "unnamedplus"
opt.fileencoding = "utf-8"

opt.termguicolors = true
opt.cursorline = true
opt.number = true
opt.relativenumber = false
opt.numberwidth = 4
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.splitbelow = true
opt.splitright = true

opt.showmode = false
opt.showtabline = 2
opt.pumheight = 10
opt.timeoutlen = 1000
opt.updatetime = 200
opt.cmdheight = 1

opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

opt.whichwrap:append("<,>,[,],h,l")
opt.iskeyword:append("-")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},

	-- LSP install + config
	{ "mason-org/mason.nvim", opts = {} },
	{ "neovim/nvim-lspconfig" },
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls", "pyright", "clangd", "bashls" },
			automatic_installation = true,
		},
	},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "stylua", "ruff", "clang-format", "beautysh" },
			})
		end,
	},

	-- Completion
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		opts = {
			keymap = { preset = "default" },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "c", "cpp", "lua", "python", "bash", "json", "yaml", "markdown" },
			highlight = { enable = true },
			indent = { enable = true },
		},
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = { timeout_ms = 1500, lsp_fallback = true },
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				sh = { "beautysh" },
			},
		},
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
	},

	-- Nvim-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view = { width = 35 },
			filters = { dotfiles = false },
		},
	},

	-- Tabs
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {},
	},

	-- Git signs
	{ "lewis6991/gitsigns.nvim", opts = {} },

	-- Statusline
	{ "nvim-lualine/lualine.nvim", opts = { options = { icons_enabled = true } } },
})

-- Keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true })
end)

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.lsp.enable({ "lua_ls", "pyright", "clangd", "bashls" })

-- LSP diagnostics options setup
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.HINT] = "󰌶",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	virtual_text = false,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

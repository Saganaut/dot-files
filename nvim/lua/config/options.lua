-- Core editor settings. Set the leader before lazy loads so plugin mappings pick it up.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"        -- avoid layout shift when signs appear
opt.termguicolors = true      -- truecolor; required for the theme to look right
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.showmode = false          -- lualine already shows the mode
opt.laststatus = 3            -- single global statusline
opt.pumheight = 10            -- cap completion popup height

-- Indentation: 2 spaces, smart.
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files / persistence
opt.swapfile = false
opt.backup = false
opt.undofile = true           -- persistent undo across sessions
opt.updatetime = 250          -- faster CursorHold / gitsigns
opt.timeoutlen = 400          -- snappier which-key

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true            -- prompt instead of failing on unsaved changes

-- Use ripgrep for :grep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

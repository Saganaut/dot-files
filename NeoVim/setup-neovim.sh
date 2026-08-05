#!/usr/bin/env bash
#
# setup-neovim.sh — recreate the exact Neovim configuration on a fresh machine.
#
# It writes the full config to ~/.config/nvim, bootstraps lazy.nvim, installs all
# plugins, language servers (via Mason), formatters, and Treesitter parsers.
#
# Stack: everforest theme · lazy.nvim · treesitter · telescope · blink.cmp ·
#        LSP (vtsls, oxlint, tailwindcss, html, cssls, jdtls, lua_ls) ·
#        formatting (oxfmt for JS/TS, prettier for web) · gitsigns · neo-tree · lualine.
#
# Usage:  bash setup-neovim.sh
#
set -euo pipefail

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
PLUGIN_DIR="$NVIM_DIR/lua/plugins"
CONFIG_DIR="$NVIM_DIR/lua/config"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Prerequisite checks
# ---------------------------------------------------------------------------
say "Checking prerequisites"

command -v nvim >/dev/null || die "neovim is not installed."
NVIM_VER=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
NVIM_MAJOR=${NVIM_VER%%.*}; NVIM_MINOR=${NVIM_VER##*.}
if [ "$NVIM_MAJOR" -eq 0 ] && [ "$NVIM_MINOR" -lt 11 ]; then
  die "Neovim >= 0.11 required (found $NVIM_VER) — this config uses the native vim.lsp.config API."
fi
say "  neovim $NVIM_VER OK"

REQUIRED=(git make cc node npm)
MISSING=()
for c in "${REQUIRED[@]}"; do command -v "$c" >/dev/null || MISSING+=("$c"); done
[ ${#MISSING[@]} -eq 0 ] || die "Missing required tools: ${MISSING[*]}"
say "  git/make/cc/node/npm OK"

command -v rg >/dev/null || warn "ripgrep (rg) not found — Telescope live_grep needs it."
command -v fd >/dev/null || warn "fd not found — Telescope file finding is faster with it."
command -v java >/dev/null || warn "java not found — the jdtls (Java) server will not start until a JDK 21+ is installed."

# ---------------------------------------------------------------------------
# 2. Back up any existing config
# ---------------------------------------------------------------------------
if [ -e "$NVIM_DIR" ]; then
  BACKUP="$NVIM_DIR.backup.$(date +%Y%m%d%H%M%S)"
  warn "Existing config found — moving it to $BACKUP"
  mv "$NVIM_DIR" "$BACKUP"
fi
mkdir -p "$PLUGIN_DIR" "$CONFIG_DIR"

# ---------------------------------------------------------------------------
# 3. Write config files
# ---------------------------------------------------------------------------
say "Writing config files to $NVIM_DIR"

cat > "$NVIM_DIR/init.lua" <<'LUA_EOF'
-- Entry point. Keep this thin: load core settings, then bootstrap the plugin manager.
require("config.options")
require("config.keymaps")
require("config.lazy")
LUA_EOF

cat > "$CONFIG_DIR/options.lua" <<'LUA_EOF'
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
LUA_EOF

cat > "$CONFIG_DIR/keymaps.lua" <<'LUA_EOF'
-- General keymaps. Plugin-specific maps live with their plugin spec.
local map = vim.keymap.set

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Better window navigation.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows with arrows.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move selected lines up/down.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centred on jumps/searches.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Stay in indent mode when shifting in visual.
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Don't clobber the yank register when pasting over a selection.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

-- Quick save / quit.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Buffer navigation.
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Splits.
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>sc", "<C-w>q", { desc = "Close split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })

-- Tabs.
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
map("n", "<leader>tl", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>th", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tt", "<cmd>tabs<CR>", { desc = "List tabs" })

-- Diagnostics.
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
LUA_EOF

cat > "$CONFIG_DIR/lazy.lua" <<'LUA_EOF'
-- Bootstrap lazy.nvim (clones it on first launch) and load every spec under lua/plugins/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = { lazy = true },        -- plugins lazy-load unless they opt out
  install = { colorscheme = { "everforest" } },
  checker = { enabled = true, notify = false }, -- background update check, no nagging
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Disable built-in plugins we don't use, for a faster startup.
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
        "netrwPlugin", "matchit", "matchparen",
      },
    },
  },
})

-- Open the lazy UI.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<CR>", { desc = "Lazy" })
LUA_EOF

cat > "$PLUGIN_DIR/colorscheme.lua" <<'LUA_EOF'
-- Everforest theme (Lua port). Loaded eagerly with high priority so it's the first thing applied.
return {
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    require("everforest").setup({
      background = "medium",        -- "soft" | "medium" | "hard"
      transparent_background_level = 0,
      italics = true,
      disable_italic_comments = false,
      ui_contrast = "low",
    })
    vim.cmd.colorscheme("everforest")
  end,
}
LUA_EOF

cat > "$PLUGIN_DIR/treesitter.lua" <<'LUA_EOF'
-- Treesitter: better syntax highlighting, indentation, and incremental selection.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",              -- classic stable API (the new "main" branch is a different rewrite)
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash", "c", "diff", "lua", "luadoc", "markdown", "markdown_inline",
      "python", "query", "regex", "vim", "vimdoc", "json", "yaml", "toml",
      -- web + java stack
      "javascript", "typescript", "tsx", "html", "css", "java",
    },
    auto_install = true,            -- grab parsers for new filetypes on the fly
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        node_decremental = "<bs>",
      },
    },
  },
}
LUA_EOF

cat > "$PLUGIN_DIR/telescope.lua" <<'LUA_EOF'
-- Telescope: fuzzy finder for files, text, buffers, etc. fzf-native makes sorting fast.
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
    { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
LUA_EOF

cat > "$PLUGIN_DIR/ui.lua" <<'LUA_EOF'
-- Statusline, file explorer, and icons.
return {
  -- Icons used by lualine / neo-tree / telescope.
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "everforest",
        globalstatus = true,
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle<CR>", desc = "File explorer" },
      { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Focus file explorer" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = true },
      },
      window = { width = 32 },
    },
  },
}
LUA_EOF

cat > "$PLUGIN_DIR/editor.lua" <<'LUA_EOF'
-- Small quality-of-life plugins: git signs, autopairs, keymap hints, indent guides.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Previous git hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- NOTE: no autopairs plugin — you set autoClosingBrackets/quotes = "never" in VSCode,
  -- so auto-inserted closing chars are intentionally left off here too.

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find/file" },
        { "<leader>h", group = "git hunk" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "split" },
        { "<leader>t", group = "tab" },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = { scope = { enabled = true } },
  },
}
LUA_EOF

cat > "$PLUGIN_DIR/completion.lua" <<'LUA_EOF'
-- Completion engine: blink.cmp is fast (Rust fuzzy matcher) with sane defaults.
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",                  -- use a release tag so the prebuilt binary is fetched
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = { preset = "default" },  -- <C-space> open, <C-y> accept, <C-n>/<C-p> navigate
    appearance = { nerd_font_variant = "normal" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      accept = { auto_brackets = { enabled = true } },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    signature = { enabled = true },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
LUA_EOF

cat > "$PLUGIN_DIR/lsp.lua" <<'LUA_EOF'
-- LSP setup for Nvim 0.11+/0.12 using the native vim.lsp.config / vim.lsp.enable API.
-- Mason installs the servers + tools; mason-lspconfig v2 auto-enables installed servers.
-- Base server configs come from nvim-lspconfig's `lsp/` directory; we only layer overrides.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    -- Buffer-local keymaps once a server attaches.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(event)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        map("gd", vim.lsp.buf.definition, "Goto definition")
        map("gr", vim.lsp.buf.references, "References")
        map("gI", vim.lsp.buf.implementation, "Goto implementation")
        map("gD", vim.lsp.buf.declaration, "Goto declaration")
        map("K", vim.lsp.buf.hover, "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
      end,
    })

    -- Diagnostics presentation.
    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    -- Advertise blink.cmp's completion capabilities to every server.
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- Per-server overrides (merged onto nvim-lspconfig's base configs).
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          diagnostics = { globals = { "vim" } }, -- silence "undefined global vim"
          telemetry = { enable = false },
        },
      },
    })

    -- oxlint's LSP. The Mason `oxlint` package ships only the CLI, but `oxlint --lsp`
    -- starts the language server (diagnostics + oxc.fixAll code action) — so override the
    -- default `oxc_language_server` cmd. Broaden root detection beyond .oxlintrc.json so it
    -- attaches in any JS/TS project, mirroring your VSCode oxc setup.
    vim.lsp.config("oxlint", {
      cmd = { "oxlint", "--lsp" },
      root_markers = { ".oxlintrc.json", "package.json", ".git" },
    })

    local servers = { "lua_ls", "vtsls", "oxlint", "tailwindcss", "html", "cssls", "jdtls" }

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = servers,
      automatic_enable = true, -- vim.lsp.enable() each installed server
    })

    -- Non-LSP tools (formatters) used by conform.nvim.
    require("mason-tool-installer").setup({
      ensure_installed = { "oxfmt", "prettier" },
      run_on_start = true,
    })
  end,
}
LUA_EOF

cat > "$PLUGIN_DIR/formatting.lua" <<'LUA_EOF'
-- Formatting via conform.nvim, matching your VSCode setup:
--   JS/TS/React -> oxfmt (the oxc formatter, = oxc.oxc-vscode)
--   HTML/CSS/JSON/YAML/Markdown -> prettier (= esbenp.prettier-vscode)
--   Java -> jdtls,  Lua -> lua_ls   (via LSP fallback)
-- On save it also runs oxlint's `oxc.fixAll` for JS/TS, mirroring source.fixAll.oxc.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  keys = {
    { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format buffer" },
  },
  opts = {
    formatters_by_ft = {
      javascript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescript = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      -- java/lua have no entry on purpose -> conform falls back to the LSP formatter.
    },
    formatters = {
      oxfmt = {
        command = "oxfmt",
        args = { "--stdin-filepath", "$FILENAME" },
        stdin = true,
      },
    },
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    -- Run oxlint's fixAll, then format, on every save (deterministic order).
    local function oxlint_fix_all(bufnr)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "oxlint" })) do
        pcall(function()
          client:request_sync("workspace/executeCommand", {
            command = "oxc.fixAll",
            arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
          }, 1000, bufnr)
        end)
      end
    end

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft:match("javascript") or ft:match("typescript") then
          oxlint_fix_all(args.buf)
        end
        conform.format({ bufnr = args.buf, lsp_format = "fallback", timeout_ms = 2000 })
      end,
    })

    -- Manually trigger oxlint fixAll.
    vim.keymap.set("n", "<leader>cl", function()
      oxlint_fix_all(0)
    end, { desc = "oxlint fix all" })
  end,
}
LUA_EOF

# ---------------------------------------------------------------------------
# 4. Bootstrap lazy.nvim and install all plugins (headless)
# ---------------------------------------------------------------------------
say "Installing plugins (lazy.nvim sync) — this clones repos and runs build steps"
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

# ---------------------------------------------------------------------------
# 5. Install language servers + formatters via Mason (blocking)
# ---------------------------------------------------------------------------
say "Installing language servers and formatters (Mason)"
MASON_LUA="$(mktemp /tmp/mason_install.XXXXXX.lua)"
cat > "$MASON_LUA" <<'LUA_EOF'
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/mason.nvim")
require("mason").setup()
local registry = require("mason-registry")
local pkgs = {
  "lua-language-server", "vtsls", "oxlint", "tailwindcss-language-server",
  "html-lsp", "css-lsp", "jdtls", "oxfmt", "prettier",
}
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)
for _, name in ipairs(pkgs) do
  local ok, p = pcall(registry.get_package, name)
  if ok and not p:is_installed() then p:install() end
end
vim.wait(600000, function()
  for _, name in ipairs(pkgs) do
    local ok, p = pcall(registry.get_package, name)
    if ok and not p:is_installed() then return false end
  end
  return true
end, 1000)
for _, name in ipairs(pkgs) do
  local ok, p = pcall(registry.get_package, name)
  print(((ok and p:is_installed()) and "OK   " or "FAIL ") .. name)
end
LUA_EOF
nvim --headless -u NONE -l "$MASON_LUA" 2>&1 | grep -E "^(OK|FAIL)" || true
rm -f "$MASON_LUA"

# ---------------------------------------------------------------------------
# 6. Compile Treesitter parsers (headless, synchronous)
# ---------------------------------------------------------------------------
say "Compiling Treesitter parsers"
TS_FILE="$(mktemp /tmp/ts_probe.XXXXXX.lua)"
printf 'local _ = 1\n' > "$TS_FILE"
nvim --headless "$TS_FILE" "+sleep 500m" \
  "+TSInstallSync bash c diff lua luadoc markdown markdown_inline python query regex vim vimdoc json yaml toml javascript typescript tsx html css java" \
  +qa 2>/dev/null || true
rm -f "$TS_FILE"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
say "Done. Launch with: nvim"
warn "First Java file open takes ~30-60s while jdtls builds its workspace index."

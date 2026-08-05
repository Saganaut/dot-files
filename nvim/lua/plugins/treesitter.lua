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

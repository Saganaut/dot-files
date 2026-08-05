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

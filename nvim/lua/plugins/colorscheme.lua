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

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

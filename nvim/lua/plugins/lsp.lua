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

    -- Enable Lombok in jdtls. The nvim-lspconfig base jdtls config turns each
    -- whitespace-separated token in $JDTLS_JVM_ARGS into a `--jvm-arg=`, so this
    -- attaches Lombok's annotation processor as a Java agent on the language
    -- server's JVM. Without it jdtls (ECJ) reports false "undefined method"
    -- errors for every @Data/@AllArgsConstructor-generated member. The jar is
    -- the one Mason bundles with the jdtls package.
    vim.env.JDTLS_JVM_ARGS = "-javaagent:"
      .. vim.fn.stdpath("data")
      .. "/mason/packages/jdtls/lombok.jar"

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

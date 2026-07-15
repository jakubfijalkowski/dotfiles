require("blink.cmp").setup({
  -- 'super-tab' reproduces coc's <Tab>/<S-Tab> flow: <Tab> accepts the menu or
  -- jumps the snippet placeholder forward, <S-Tab> jumps it backward.
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },                                    -- coc#pum#confirm
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" }, -- coc#refresh
  },

  completion = {
    -- With Enter-to-accept, don't preselect: <CR> then only accepts what you
    -- actively selected, and otherwise inserts a newline.
    list = { selection = { preselect = false } },
    documentation = { auto_show = true },
  },

  -- Signature help (replaces coc's showSignatureHelp on placeholder jump).
  signature = { enabled = true },

  -- Snippets use Neovim's native vim.snippet API (blink's default).
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
})

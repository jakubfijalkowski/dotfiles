require("blink.cmp").setup({
  -- C-y accepts; C-n/C-p or arrows move the selection; Tab/S-Tab jump snippet
  -- placeholders. Enter stays a plain newline.
  keymap = {
    preset = "default",
  },

  completion = {
    -- Nothing is preselected or inserted until you explicitly accept with C-y,
    -- so a completion never lands by accident.
    list = { selection = { preselect = false, auto_insert = false } },
    documentation = { auto_show = true },
    menu = {
      draw = {
        -- Highlight completion labels with treesitter.
        treesitter = { "lsp" },
        -- element icon | label + description | kind name
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "kind" },
        },
      },
    },
  },

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

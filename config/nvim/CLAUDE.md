# Neovim configuration

Personal Neovim config in a dotfiles repo (`config/nvim`), managed with
[lazy.nvim] and running on Arch Linux.

## Core principles (read first)

1. **Always target the latest Neovim.** This config tracks the newest stable
   Neovim (currently 0.12.x) and freely uses the newest built-in APIs. Prefer
   native functionality over a plugin whenever Neovim ships it. Do **not** write
   back-compat shims or code for older versions.
2. **Prefer cutting-edge plugins.** Favor modern, actively-developed, native-Lua
   plugins over established-but-dated ones — e.g. `blink.cmp` over `nvim-cmp`,
   native `vim.lsp` over `coc.nvim`, `rustaceanvim`, `lazydev.nvim` over
   `neodev.nvim`, `mason-org/*`. When adding a plugin, pick the current
   community front-runner.
3. **Lua is the configuration language.** Everything is Lua — no Vimscript beyond
   unavoidable `vim.cmd` / `<Plug>` bridges. New config goes in a `lua/` module.

## Working with native APIs

Neovim's built-in APIs move quickly. Prefer the current native API for a task
over a plugin or an older idiom, and treat deprecation warnings as work to do.
Before copying a pattern from a blog post or an existing config, confirm it is
not deprecated (`:help news`, `:help deprecated`, `:checkhealth`) — many
widely-shared snippets predate their native replacements.

## Layout

`init.lua` bootstraps lazy.nvim, declares the plugin list, then `require`s the
modules below in load order:

| Module | Responsibility |
|---|---|
| `lua/overrides.lua` | earliest overrides (loaded first) |
| `lua/load_lazy.lua` | lazy.nvim bootstrap |
| `lua/globals.lua` | global `vim.o` / `vim.g` options, UI (`winborder`), `notify` |
| `lua/editor.lua` | indentation, folding, treesitter, line numbers |
| `lua/layout.lua` | UI plugins: lualine, telescope (+ ui-select), nvim-tree, undotree |
| `lua/lsp.lua` | native LSP: mason, `vim.lsp.config` per server, diagnostics, codelens, `LspAttach` keymaps |
| `lua/completion.lua` | blink.cmp |
| `lua/formatting.lua` | conform.nvim |
| `lua/keymaps.lua` | global (non-`LspAttach`) keymaps |
| `lua/helpers.lua` | small helper functions |

## LSP stack

- **Servers** are installed and auto-enabled by `mason.nvim` +
  `mason-lspconfig.nvim` (`ensure_installed = lua_ls, jsonls, yamlls,
  terraformls`). Per-server settings go through `vim.lsp.config(name, {...})`.
- **Rust is special**: owned by **rustaceanvim**. NEVER also enable
  `rust_analyzer` — it is excluded in mason-lspconfig `automatic_enable.exclude`,
  and enabling it elsewhere causes duplicate clients. rust-analyzer settings live
  in `vim.g.rustaceanvim`. Requires the binary: `rustup component add rust-analyzer`.
- **Completion capabilities** come from `blink.cmp` via
  `vim.lsp.config("*", { capabilities = ... })`.
- **lua_ls** gets Neovim runtime/plugin awareness from `lazydev.nvim`.
- Mason's `ensure_installed` is **skipped in headless mode** (CI safety) — servers
  install on the first interactive launch.

## Formatting

- `conform.nvim` with `lsp_format = "fallback"`. Lua uses **stylua**
  (`:MasonInstall stylua`); everything else formats via its LSP.
- Lua style is enforced by `.stylua.toml` (2-space indent, 100 column width,
  double quotes) — it mirrors the editor settings. Run stylua / `<Leader>=` on
  Lua before committing.

## Repo conventions

- Commits are **GPG-signed** — a commit may block on a pinentry passphrase prompt
  that only the user can answer.
- Sanity-check that the config loads headless: `nvim --headless -u init.lua +qa`
  (should exit 0 with no errors).

[lazy.nvim]: https://github.com/folke/lazy.nvim

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

## Deployment

`~/.config/nvim` is a single symlink to this directory (see `bootstrap`), so
`lazy-lock.json` lands here and is **tracked** — commit it with plugin changes,
and roll back a bad update with `:Lazy restore`. Swap, backup and undo files use
Neovim's defaults under `stdpath("state")`; don't override them.

## Layout

`init.lua` bootstraps lazy.nvim, declares the plugin list, then `require`s the
modules below in load order:

| Module | Responsibility |
|---|---|
| `lua/overrides.lua` | earliest overrides (loaded first) |
| `lua/load_lazy.lua` | lazy.nvim bootstrap |
| `lua/globals.lua` | global `vim.o` / `vim.g` options, UI (`winborder`, native `ui2` messages) |
| `lua/editor.lua` | indentation, folding, treesitter, line numbers, yank highlight, mini.surround / mini.align |
| `lua/layout.lua` | UI: lualine, gitsigns, telescope (+ ui-select), nvim-tree, mini.starter, built-in undotree, which-key |
| `lua/lsp.lua` | native LSP: mason (+ non-LSP tools), `vim.lsp.config` per server, diagnostics, codelens, `LspAttach` keymaps |
| `lua/completion.lua` | blink.cmp |
| `lua/formatting.lua` | conform.nvim |
| `lua/keymaps.lua` | global (non-`LspAttach`) keymaps |

Built-ins replace plugins where Neovim ships them: `:Undotree`
(`packadd nvim.undotree`), `ui2` instead of nvim-notify, native `gc` comments.
The remaining small editing plugins come from **mini.nvim** (starter, surround
with vim-surround keys, align, bufremove).

Treesitter: parsers are listed once in `editor.lua` (`ts_langs`); a generic
`FileType` autocmd starts highlighting for any filetype with a parser and
treesitter indent only for those listed languages with an `indents` query.

## LSP stack

- **Servers** are installed and auto-enabled by `mason.nvim` +
  `mason-lspconfig.nvim` (`ensure_installed = lua_ls, jsonls, yamlls,
  terraformls, bashls, tombi`). Per-server settings go through
  `vim.lsp.config(name, {...})`. **qmlls** is the system `qmlls6` (Qt 6), enabled
  directly with `vim.lsp.enable`; it resolves QuickShell's `qs.*` imports through
  the git-ignored `config/quickshell/.qmlls.ini` that Quickshell regenerates.
- **Non-LSP tools** (`stylua`, `shellcheck`) are installed by a small
  mason-registry loop in `lsp.lua`.
- **Schemas** for jsonls/yamlls come from `SchemaStore.nvim`; the Kubernetes
  schema is scoped to `k8s/`, `kubernetes/` and `manifests/` directories.
- **Rust is special**: owned by **rustaceanvim** (`^9`). NEVER also enable
  `rust_analyzer` — it is excluded in mason-lspconfig `automatic_enable.exclude`,
  and enabling it elsewhere causes duplicate clients. rust-analyzer settings live
  in `vim.lsp.config("rust-analyzer", ...)` (hyphen: rustaceanvim's own name,
  not lspconfig's `rust_analyzer`), which rustaceanvim merges into its server
  config. Requires the binary: `rustup component add rust-analyzer`.
- **Completion capabilities** are added by `blink.cmp` itself (its `plugin/`
  file extends `vim.lsp.config("*")`); don't set them manually.
- **lua_ls** gets Neovim runtime/plugin awareness from `lazydev.nvim`, which is
  disabled in projects with their own `.luarc.json` (e.g. `config/hypr`).
- Mason's `ensure_installed` is **skipped in headless mode** (CI safety) — servers
  install on the first interactive launch.

## Completion

`blink.cmp` runs the unreleased **v2** from its `main` branch (pinned by
`lazy-lock.json`) with the required `saghen/blink.lib` dependency. Prebuilt
fuzzy-matcher binaries only exist for release tags, so the lazy `build` step
compiles it with cargo (`require("blink.cmp").build():pwait()`, ~2 min). If the
matcher is missing after an update, run `:Lazy build blink.cmp` in a fresh
Neovim. Once 2.0 is tagged, switch the spec back to `version = "2.*"`.

## Formatting

- `conform.nvim` with `lsp_format = "fallback"`. Lua uses **stylua** (installed
  by mason, see above); everything else formats via its LSP.
- Lua style is enforced by `.stylua.toml` (2-space indent, 100 column width,
  double quotes) — it mirrors the editor settings. Run stylua / `<Leader>=` on
  Lua before committing.

## Repo conventions

- Commits are **GPG-signed** — a commit may block on a pinentry passphrase prompt
  that only the user can answer.
- Sanity-check that the config loads headless: `nvim --headless -u init.lua +qa`
  (should exit 0 with no errors).

[lazy.nvim]: https://github.com/folke/lazy.nvim

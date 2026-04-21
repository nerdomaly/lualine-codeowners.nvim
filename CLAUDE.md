# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): message` (e.g. `fix(parser): handle trailing slash`, `feat(format): add first_plus_count mode`).

## Tests

Requires Neovim and plenary at `/tmp/plenary.nvim`.

```bash
git clone --depth=1 https://github.com/nvim-lua/plenary.nvim /tmp/plenary.nvim

# All tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init='tests/minimal_init.lua'}"

# Single file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/parser_spec.lua"
```

## Architecture

Four modules under `lua/lualine-codeowners/`:

- **`parser.lua`** — `glob_to_lua` converts CODEOWNERS globs to Lua patterns (GitHub/gitignore semantics: `*` = within segment, `**` = any depth, leading/interior `/` anchors, trailing `/` = dir-only). `parse_file` returns `{ patterns, owners }[]`.
- **`lookup.lua`** — Finds repo root via `vim.fs.root(.git)`, locates CODEOWNERS via `config.locations`, matches buffer's repo-relative path against rules in reverse (last rule wins). Two caches: `parse_cache` by path+mtime, `buf_cache` by bufnr.
- **`config.lua`** — Defaults + `set(opts)`/`get()` via `vim.tbl_deep_extend`.
- **`format.lua`** — Formats owners per `display_mode` (`all`/`first`/`first_plus_count`), truncates by `max_length` using `strdisplaywidth`, prepends icon.

`lua/lualine/components/codeowners.lua` — lualine component; merges per-component options over global config at init, calls lookup+format in `update_status`.

`plugin/lualine-codeowners.lua` — entry point; registers autocommands (invalidate buf_cache on `BufEnter`/`BufDelete`, reset all caches on CODEOWNERS save) and `:CodeownersWho`.

`lua/lualine-codeowners/init.lua` — public API: `setup`, `get_owners`, `get_display`, `reset`.

`tests/fixtures/` — `simple/` and `complex/` CODEOWNERS files for specs. Extend these rather than hard-coding paths in new tests.

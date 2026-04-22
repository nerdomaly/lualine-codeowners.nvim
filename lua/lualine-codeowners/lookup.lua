local M = {}

local config = require("lualine-codeowners.config")
local parser = require("lualine-codeowners.parser")

local parse_cache = {} -- [path] = { mtime, rules }
local buf_cache = {}   -- [bufnr] = owners_list | false

local function find_codeowners(root)
  for _, rel in ipairs(config.get().locations) do
    local full = root .. "/" .. rel
    local stat = vim.uv.fs_stat(full)
    if stat and stat.type == "file" then
      return full, stat.mtime.sec
    end
  end
end

local function cached_parse(path, mtime)
  local cached = parse_cache[path]
  if cached and cached.mtime == mtime then return cached.rules end
  local rules = parser.parse_file(path)
  -- Re-stat after the read so the cached mtime reflects what was on disk
  -- at read time, not at the earlier find_codeowners call (TOCTOU guard).
  local stat2 = vim.uv.fs_stat(path)
  parse_cache[path] = { mtime = stat2 and stat2.mtime.sec or mtime, rules = rules }
  return rules
end

function M.get_owners(bufnr)
  local cached = buf_cache[bufnr]
  if cached ~= nil then
    return cached or nil
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    buf_cache[bufnr] = false
    return nil
  end

  local root = vim.fs.root(bufnr, ".git")
  if not root then
    buf_cache[bufnr] = false
    return nil
  end

  local path, mtime = find_codeowners(root)
  if not path then
    buf_cache[bufnr] = false
    return nil
  end

  local rules = cached_parse(path, mtime)
  local rel = vim.fn.fnamemodify(name, ":p"):sub(#root + 2)

  for i = #rules, 1, -1 do
    for _, p in ipairs(rules[i].patterns) do
      if rel:match(p) then
        buf_cache[bufnr] = rules[i].owners
        return rules[i].owners
      end
    end
  end

  buf_cache[bufnr] = false
  return nil
end

function M.is_codeowners_file(path)
  return vim.fs.basename(path) == "CODEOWNERS"
end

function M.reset()
  parse_cache = {}
  buf_cache = {}
end

function M.invalidate_buffer(bufnr)
  buf_cache[bufnr] = nil
end

return M

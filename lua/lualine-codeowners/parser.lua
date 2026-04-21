local M = {}

-- Translate a CODEOWNERS/gitignore-style glob to Lua patterns anchored from
-- the repo root. Best-effort: handles *, **, ?, leading /, trailing /, and
-- bare names. Does not support character classes ([a-z] etc.).
function M.glob_to_lua(glob)
  local anchored = glob:sub(1, 1) == "/" or glob:find("/", 2, true) ~= nil
  local is_dir = glob:sub(-1) == "/"
  if is_dir then glob = glob:sub(1, -2) end
  if glob:sub(1, 1) == "/" then glob = glob:sub(2) end

  local out, i = {}, 1
  while i <= #glob do
    local c = glob:sub(i, i)
    if c == "*" then
      if glob:sub(i + 1, i + 1) == "*" then
        table.insert(out, ".*")
        i = i + 2
      else
        table.insert(out, "[^/]*")
        i = i + 1
      end
    elseif c == "?" then
      table.insert(out, "[^/]")
      i = i + 1
    elseif c:match("[%(%)%%%.%+%-%[%]%^%$]") then
      table.insert(out, "%" .. c)
      i = i + 1
    else
      table.insert(out, c)
      i = i + 1
    end
  end

  local body = table.concat(out)
  -- CODEOWNERS follows gitignore semantics: a pattern without trailing slash
  -- matches both the exact path and any path under it. Lua patterns lack
  -- alternation, so we emit two suffixes (`$` and `/.*$`) and two prefixes
  -- (`^` and anywhere after a `/`) for unanchored patterns.
  local suffixes = is_dir and { "/.*$" } or { "$", "/.*$" }
  local prefixes = anchored and { "^" } or { "^", "/" }
  -- A leading "**/" means "any directory depth, including zero" — also match
  -- files directly at the repo root by emitting a second body without the prefix.
  local bodies = { body }
  if body:sub(1, 3) == ".*/" then
    table.insert(bodies, body:sub(4))
  end
  local patterns = {}
  for _, b in ipairs(bodies) do
    for _, p in ipairs(prefixes) do
      for _, s in ipairs(suffixes) do
        table.insert(patterns, p .. b .. s)
      end
    end
  end
  return patterns
end

function M.parse_file(path)
  local rules = {}
  local ok, err = pcall(function()
    for line in io.lines(path) do
      local stripped = line:gsub("^%s+", ""):gsub("%s+$", "")
      if stripped ~= "" and stripped:sub(1, 1) ~= "#" then
        local parts = {}
        for tok in stripped:gmatch("%S+") do
          table.insert(parts, tok)
        end
        if #parts >= 2 then
          local pat = table.remove(parts, 1)
          table.insert(rules, { patterns = M.glob_to_lua(pat), owners = parts })
        end
      end
    end
  end)
  if not ok then
    vim.notify("lualine-codeowners: failed to read " .. path .. ": " .. tostring(err), vim.log.levels.WARN)
  end
  return rules
end

return M

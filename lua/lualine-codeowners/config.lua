local M = {}

M.defaults = {
  icon = "\u{f0c0}",
  icon_separator = "  ",
  placeholder = "no owner",
  locations = { "CODEOWNERS", ".github/CODEOWNERS", "docs/CODEOWNERS" },
  max_length = 40,
  truncation_suffix = "\u{2026}",
  display_mode = "all",
  separator = ", ",
  show_placeholder_when_empty = true,
}

local _config = vim.deepcopy(M.defaults)

function M.set(opts)
  for _, loc in ipairs((opts or {}).locations or {}) do
    assert(not loc:find("%.%."), "lualine-codeowners: location must not contain '..': " .. loc)
    assert(loc:sub(1, 1) ~= "/", "lualine-codeowners: location must not be an absolute path: " .. loc)
  end
  _config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

function M.get()
  return _config
end

return M

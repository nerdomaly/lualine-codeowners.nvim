local M = {}

local config = require("lualine-codeowners.config")
local lookup = require("lualine-codeowners.lookup")
local format = require("lualine-codeowners.format")

function M.setup(opts)
  config.set(opts)
end

function M.get_owners(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return lookup.get_owners(bufnr)
end

function M.get_display(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local owners = lookup.get_owners(bufnr)
  return format.display(owners, config.get())
end

function M.reset()
  lookup.reset()
end

return M

local Component = require("lualine.component"):extend()

function Component:init(options)
  Component.super.init(self, options)
  self.local_config = vim.tbl_deep_extend(
    "force",
    require("lualine-codeowners.config").get(),
    options or {}
  )
end

function Component:update_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local owners = require("lualine-codeowners.lookup").get_owners(bufnr)
  return require("lualine-codeowners.format").display(owners, self.local_config)
end

return Component

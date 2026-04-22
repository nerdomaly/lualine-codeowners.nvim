if vim.g.loaded_lualine_codeowners then return end
vim.g.loaded_lualine_codeowners = true

local lookup = require("lualine-codeowners.lookup")

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufDelete" }, {
  group = vim.api.nvim_create_augroup("LualineCodeowners", { clear = true }),
  callback = function(args)
    if args.event == "BufDelete" then
      lookup.invalidate_buffer(args.buf)
    elseif args.event == "BufWritePost" and lookup.is_codeowners_file(args.file) then
      lookup.reset()
    else
      lookup.invalidate_buffer(args.buf)
    end
  end,
})

vim.api.nvim_create_user_command("CodeownersWho", function()
  local owners = require("lualine-codeowners").get_owners()
  if not owners then
    vim.notify("No CODEOWNERS match for this buffer", vim.log.levels.INFO)
  else
    vim.notify(table.concat(owners, ", "), vim.log.levels.INFO)
  end
end, { desc = "Show CODEOWNERS for the current buffer" })

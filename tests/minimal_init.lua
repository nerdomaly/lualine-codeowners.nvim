local plenary_dir = "/tmp/plenary.nvim"

if vim.fn.isdirectory(plenary_dir) == 0 then
  vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

vim.opt.runtimepath:append(plenary_dir)
vim.opt.runtimepath:append(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h"))

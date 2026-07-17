-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- nvm node is not on PATH when Neovim is launched from GUI/non-login shell
local nvm_dir = vim.fn.expand("~/.nvm/versions/node")
if vim.fn.isdirectory(nvm_dir) == 1 then
  local alias_file = vim.fn.expand("~/.nvm/alias/default")
  local ok, lines = pcall(vim.fn.readfile, alias_file)
  if ok and lines[1] then
    local default = vim.fn.trim(lines[1])
    local matches = vim.fn.glob(nvm_dir .. "/v" .. default .. "*/bin", false, true)
    if #matches > 0 then
      table.sort(matches)
      vim.env.PATH = matches[#matches] .. ":" .. vim.env.PATH
    end
  end
end

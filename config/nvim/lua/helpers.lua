local M = {}

function M.LocalDataFolder(f)
  return vim.fs.normalize("~/.local/share/nvim/" .. f)
end

return M

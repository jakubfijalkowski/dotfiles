vim.o.tagfunc = "CocTagFunc"
vim.g.coc_snippet_next = "<tab>"

vim.api.nvim_create_autocmd("User",
  { pattern = "CocJumpPlaceholder", callback = function() vim.fn.CocActionAsync("showSignatureHelp") end })

vim.api.nvim_create_autocmd("FileType",
  {
    pattern = "lua",
    callback = function()
      vim.fn["coc#config"]("Lua.workspace.library", vim.api.nvim_get_runtime_file('', true))
    end,
  })

function _G.coc_show_docs()
  local cw = vim.fn.expand("<cword>")
  if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
    vim.cmd("h " .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync("doHover")
  else
    vim.notify("Coc.nvim has not been loaded yet.", vim.log.levels.ERROR)
  end
end

function _G.coc_check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match("%s")
end

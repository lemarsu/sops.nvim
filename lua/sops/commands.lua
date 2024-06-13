local config = require 'sops.config'
local cmd = vim.cmd
local fn = vim.fn
local M = {}

local function sops_filter(...)
  local last_line = fn.getpos('$')[2]
  cmd { cmd = '!', args = { config.binary, ... }, range = { 1, last_line } }
end

local function ensure_not_modified()
  if vim.bo.modified then
    cmd.edit()
    if vim.bo.modified then
      return false
    end
  end
  return true
end

function M.decrypt_buffer()
  if not ensure_not_modified() then
    return
  end

  sops_filter('-d', '%')
end

function M.encrypt_buffer()
  if not ensure_not_modified() then
    return
  end

  sops_filter('-e', '%')
end

function M.sops_edit()
  local bufnr = fn.bufnr()
  local file_name = fn.bufname(bufnr)
  if file_name:sub(1, 1) ~= "/" then
    local pwd = fn.getcwd()
    if pwd:sub(-2, 1) then
      pwd = pwd .. '/'
    end
    file_name = pwd .. file_name
  end
  cmd.edit { args = { 'sops://' .. file_name } }
end

function M.sops_edit_close()
  local bufnr = fn.bufnr()
  local file_name = fn.bufname(bufnr)
  if file_name:sub(1, 7) ~= "sops://" then
    vim.api.nvim_err_writeln("Not a sops file!")
    return
  end
  cmd.edit { args = { file_name:sub(8) } }
  cmd.bwipeout { count = bufnr }
end

return M

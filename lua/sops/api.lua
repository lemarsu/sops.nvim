local notify = require 'sops.notify'
local sops = require 'sops.sops'
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local M = {}

local function ensure_not_modified()
  if vim.bo.modified then
    cmd.edit()
    if vim.bo.modified then
      return false
    end
  end
  return true
end

local function get_file_name()
  local bufnr = fn.bufnr()
  return fn.bufname(bufnr)
end

local function is_sops_edit()
  return get_file_name():sub(1, 7) == 'sops://'
end

local function ensure_not_sops_edit()
  local ret = not is_sops_edit()
  if not ret then
    notify.error('You are already editing a sops file')
  end
  return ret
end

local function ensure_sops_edit()
  local ret = is_sops_edit()
  if not ret then
    notify.error('You are not editing a sops file')
  end
  return ret
end

function M.decrypt_buffer()
  if not ensure_not_modified() then
    return
  end

  sops.read_decrypted_file(vim.fn.expand('%'), function(contents)
    api.nvim_buf_set_lines(vim.fn.bufnr(), 0, -1, false, contents)
  end)
end

function M.encrypt_buffer()
  if not ensure_not_modified() then
    return
  end

  sops.read_encrypted_file(vim.fn.expand('%'), function(contents)
    api.nvim_buf_set_lines(vim.fn.bufnr(), 0, -1, false, contents)
  end)
end

function M.edit()
  if not ensure_not_sops_edit() then
    return
  end
  local file_name = get_file_name()

  sops.read_decrypted_file(vim.fn.expand('%'), function(contents)
    if file_name:sub(1, 1) ~= '/' then
      local pwd = fn.getcwd()
      if pwd == '/' then
        file_name = pwd .. file_name
      else
        file_name = pwd .. '/' .. file_name
      end
    end
    cmd.edit { args = { 'sops://' .. file_name } }
  end)
end

function M.close()
  if not ensure_sops_edit() then
    return
  end
  local bufnr = fn.bufnr()
  local file_name = get_file_name():sub(8)

  if not vim.bo.modified then
    cmd.edit { args = { file_name } }
    cmd.bwipeout { count = bufnr }
    return
  end

  sops.read_buffer_as_encrypted_file(file_name, bufnr, function(contents, code)
    vim.bo[bufnr].modified = false
    cmd.edit { bang = true, args = { file_name } }
    api.nvim_buf_set_lines(fn.bufnr(), 0, -1, false, contents)
    if code ~= 200 then
      vim.bo.modified = true
    end
    cmd.bwipeout { bang = true, count = bufnr }
  end)
end

function M.toggle()
  if is_sops_edit() then
    M.close()
  else
    M.edit()
  end
end

return M

local notify = require 'sops.notify'
local sops = require 'sops.sops'
local utils = require 'sops.utils'
local api = vim.api
local cmd = vim.cmd
local v = vim.v

local SOPS_BUFF_IS_DECRYPTED = '__sops_buff_is_decrypted'

local M = {}

local function get_editor_path()
  local Path = require 'plenary.path'
  return Path:new(utils.get_script_path()):joinpath('../../editor.lua'):absolute()
end

function M.read_encrypted_file(ev)
  local file = ev.file:sub(8)
  vim.bo.swapfile = false
  sops.read_decrypted_file(
    file,
    function(file_content)
      api.nvim_buf_set_lines(ev.buf, 0, -1, false, file_content)
      vim.opt_local.modified = false
      vim.api.nvim_buf_set_var(ev.buf, SOPS_BUFF_IS_DECRYPTED, true)

      cmd { cmd = 'do', args = { 'BufReadPost', file } }
    end,
    function()
      vim.api.nvim_buf_set_var(ev.buf, SOPS_BUFF_IS_DECRYPTED, false)
    end
  )
end

function M.write_encrypted_file(ev)
  local file = ev.file:sub(8)
  local editor = get_editor_path()
  local stderr = {}

  if not vim.api.nvim_buf_get_var(ev.buf, SOPS_BUFF_IS_DECRYPTED) then
    notify.error 'File is not properly decrypted, refusing to save'
    return
  end

  sops.call_sops {
    args = { file },
    env = {
      EDITOR = v.progpath .. ' -l ' .. editor,
      SOPS_NVIM_SOCKET = v.servername,
      SOPS_NVIM_BUFNR = ev.buf,
    },
    success_codes = { 0, 200 },
    on_success = function(ctx)
      if ctx.code == 200 then
        notify.info 'File has not changed'
      else -- code 0
        notify.info 'File saved'
      end
      vim.opt_local.modified = false
      cmd { cmd = 'do', args = { 'BufWritePost', file } }
    end
  }
end

return M

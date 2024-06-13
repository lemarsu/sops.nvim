local config = require 'sops.config'
local utils = require 'sops.utils'
local api = vim.api
local cmd = vim.cmd
local v = vim.v

local M = {}

local function get_editor_path()
  local Path = require 'plenary.path'
  return Path:new(utils.get_script_path()):joinpath('../../editor.lua'):absolute()
end

function M.read_encrypted_file(ev)
  local file = ev.file:sub(8)
  local file_content = {}
  local Job = require 'plenary.job'
  local job = Job:new {
    command = config.binary,
    args = { "-d", file },
    on_stdout = function(err, data, _job)
      if err then
        api.nvim_err_writeln "SOPS: Unable to read file"
        return
      end
      file_content[#file_content + 1] = data
    end,
    on_exit = function(j, code, _signal)
      if code ~= 0 then
        print("SOPS: Error while decrypting file: " .. code)
        print(j:result())
        return
      end

      vim.schedule(function()
        api.nvim_buf_set_lines(ev.buf, 0, -1, false, file_content)
        vim.opt_local.modified = false

        cmd { cmd = 'do', args = { 'BufReadPost', file } }
      end)
    end
  }
  job:sync()
end

function M.write_encrypted_file(ev)
  local file = ev.file:sub(8)
  local editor = get_editor_path()
  local Job = require 'plenary.job'
  local job = Job:new {
    command = config.binary,
    args = { file },
    env = {
      SOPS_NVIM_SOCKET = v.servername,
      SOPS_NVIM_BUFNR = ev.buf,
      EDITOR = v.progpath .. ' -l ' .. editor,
      PATH = vim.loop.os_environ()['PATH'],
      HOME = vim.loop.os_homedir(),
    },
    on_stderr = function(err, data, _job)
      if err then
        -- api.nvim_err_writeln "SOPS: Unable to write file"
        print "SOPS: Unable to write file"
        print(err)
        return
      end
      print(data)
    end,
    on_stdout = function(err, data, _job)
      if err then
        -- api.nvim_err_writeln "SOPS: Unable to write file"
        print "SOPS: Unable to write file"
        print(err)
        return
      end
      print(data)
    end,
    on_exit = function(j, code, _signal)
      if code ~= 0 and code ~= 200 then
        print("SOPS: Error while encrypting file: " .. code)
        print(j:result())
        return
      end

      vim.schedule(function()
        vim.opt_local.modified = false
        cmd { cmd = 'do', args = { 'BufWritePost', file } }
      end)
    end
  }
  job:start()
end

return M

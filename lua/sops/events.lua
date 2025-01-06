local config = require 'sops.config'
local utils = require 'sops.utils'
local notify = require 'sops.notify'
local api = vim.api
local cmd = vim.cmd
local v = vim.v

local SOPS_BUFF_IS_DECRYPTED = '__sops_buff_is_decrypted'

local M = {}

local function get_editor_path()
  local Path = require 'plenary.path'
  return Path:new(utils.get_script_path()):joinpath('../../editor.lua'):absolute()
end

local function call_sops(opts)
  local job_opts = vim.tbl_extend('force', {}, opts, {
    command = config.binary,
  })

  local Job = require 'plenary.job'
  local success, job = pcall(Job.new, Job, job_opts)

  if not success then
    notify.error 'SOPS: Unable to call sops.\nIs sops binary installed ?'
    return nil
  end
  return job
end

local function build_env(mandatory)
  local env = {}
  local os_env = vim.loop.os_environ()

  -- Following environment variables
  for _, name in ipairs(config.sops.follow) do
    env[name] = os_env[name]
  end

  -- Setting defined varibales
  for name, val in pairs(config.sops.env) do
    env[name] = val
  end

  return vim.tbl_extend('force', env, mandatory)
end

function M.read_encrypted_file(ev)
  local file = ev.file:sub(8)
  vim.bo.swapfile = false
  local file_content = {}
  local stderr = {}
  local job = call_sops {
    args = { '-d', file },
    on_stdout = function(err, data, _job)
      if err then
        notify.error('SOPS: Unable to read file: ' .. vim.inspect(err))
        return
      end
      file_content[#file_content + 1] = data
    end,
    on_stderr = function(err, data, _job)
      if err then
        notify.error('SOPS: Unable to read file: ' .. vim.inspect(err))
        return
      end
      stderr[#stderr + 1] = data
    end,
    on_exit = function(j, code, _signal)
      if code ~= 0 then
        vim.schedule(function()
          notify.error('SOPS: Error while decrypting file\n' .. vim.fn.join(stderr, '\n'))
          vim.api.nvim_buf_set_var(ev.buf, SOPS_BUFF_IS_DECRYPTED, false)
        end)
        return
      end

      vim.schedule(function()
        api.nvim_buf_set_lines(ev.buf, 0, -1, false, file_content)
        vim.opt_local.modified = false
        vim.api.nvim_buf_set_var(ev.buf, SOPS_BUFF_IS_DECRYPTED, true)

        cmd { cmd = 'do', args = { 'BufReadPost', file } }
      end)
    end
  }

  if job then
    job:sync()
  end
end

function M.write_encrypted_file(ev)
  local file = ev.file:sub(8)
  local editor = get_editor_path()
  local stderr = {}

  if not vim.api.nvim_buf_get_var(ev.buf, SOPS_BUFF_IS_DECRYPTED) then
    notify.error 'File is not properly decrypted, refusing to save'
    return
  end

  local env = {
    SOPS_NVIM_SOCKET = v.servername,
    SOPS_NVIM_BUFNR = ev.buf,
    EDITOR = v.progpath .. ' -l ' .. editor,
    PATH = vim.loop.os_environ()['PATH'],
    HOME = vim.loop.os_homedir(),
  }

  local job = call_sops {
    args = { file },
    env = build_env(env),
    on_stderr = function(err, data, _job)
      if err then
        -- api.nvim_err_writeln 'SOPS: Unable to write file'
        notify.error('SOPS: Unable to read sops stderr: ' .. err)
        return
      end
      stderr[#stderr + 1] = data
    end,
    on_stdout = function(err, data, _job)
      if err then
        -- api.nvim_err_writeln 'SOPS: Unable to write file'
        notify.error('SOPS: Unable to sops stdout: ' .. err)
        return
      end
      print(data)
    end,
    on_exit = function(j, code, _signal)
      if code ~= 0 and code ~= 200 then
        vim.schedule(function()
          notify.error('SOPS: Error while encrypting file\n' .. vim.fn.join(stderr, '\n'))
        end)
        return
      end

      vim.schedule(function()
        vim.opt_local.modified = false
        cmd { cmd = 'do', args = { 'BufWritePost', file } }
      end)
    end
  }

  if job then
    job:start()
  end
end

return M

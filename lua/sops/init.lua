local utils = require 'sops.utils'
local Job = require 'plenary.job'
local Path = require 'plenary.path'
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local v = vim.v

local function ensure_not_modified()
  if vim.bo.modified then
    cmd.edit()
    if vim.bo.modified then
      return false
    end
  end
  return true
end

local function decrypt_buffer()
  if not ensure_not_modified() then
    return
  end
  cmd('%! sops -d %')
end

local function encrypt_buffer()
  if not ensure_not_modified() then
    return
  end
  cmd('%! sops -e %')
end

local function sops_edit()
  local bufnr = fn.bufnr()
  local file_name = fn.bufname(bufnr)
  if file_name:sub(1, 1) ~= "/" then
    local pwd = fn.getcwd()
    if pwd:sub(-2, 1) then
      pwd = pwd .. '/'
    end
    file_name = pwd .. file_name
  end
  cmd('e sops://' .. file_name)
end

local function sops_edit_close()
  local bufnr = fn.bufnr()
  local file_name = fn.bufname(bufnr)
  if file_name:sub(1, 7) ~= "sops://" then
    vim.api.nvim_err_writeln("Not a sops file!")
    return
  end
  cmd.edit { args = { file_name:sub(8) } }
  cmd.bwipeout { count = bufnr }
end

local function read_encrypted_file(ev)
  local file = ev.file:sub(8)
  local file_content = {}
  local job = Job:new {
    command = "sops",
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

        cmd('do BufReadPost ' .. file)
      end)
    end
  }
  job:sync()
end

local function get_editor_path()
  return Path:new(utils.get_script_path()):joinpath('../../editor.lua'):absolute()
end

local function write_encrypted_file(ev)
  local file = ev.file:sub(8)
  local editor = get_editor_path()
  local job = Job:new {
    command = "sops",
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
        cmd('do BufWritePost ' .. file)
      end)
    end
  }
  job:start()
end

local function setup_autocmds()
  local group_id = api.nvim_create_augroup("Sops", {
    clear = true
  })

  api.nvim_create_autocmd('BufReadCmd', {
    pattern = 'sops://*',
    group = group_id,
    callback = read_encrypted_file,
  })

  api.nvim_create_autocmd('BufWriteCmd', {
    pattern = 'sops://*',
    group = group_id,
    callback = write_encrypted_file,
  })
end

local function setup_legendary()
  local success, legendary = pcall(require, 'legendary')
  if success then
    legendary.itemgroups({
      itemgroup = 'SOPS',
      icon = '',
      description = 'Sops plugin commands',
      commands = {
        { ':SopsDecrypt',   description = 'Decrypt sops file' },
        { ':SopsEncrypt',   description = 'Encrypt sops file' },
        { ':SopsEdit',      description = 'Edit sops file' },
        { ':SopsEditClose', description = 'Close sops file' },
      },
    })
  end
end

local function setup_commands()
  api.nvim_create_user_command('SopsDecrypt', function(_opts)
    decrypt_buffer()
  end, { desc = 'Decrypt sops file' })

  api.nvim_create_user_command('SopsEncrypt', function(_opts)
    encrypt_buffer()
  end, { desc = 'Encrypt sops file' })

  api.nvim_create_user_command('SopsEdit', function(_opts)
    sops_edit()
  end, { desc = 'Edit sops file' })

  api.nvim_create_user_command('SopsEditClose', function(_opts)
    sops_edit_close()
  end, { desc = 'Close sops file' })
end

local function setup()
  setup_commands()
  setup_autocmds()
  setup_legendary()
end

local M = {
  setup = setup,
  sops_edit = sops_edit,
  sops_edit_close = sops_edit_close,
}

return M

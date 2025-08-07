local config = require 'sops.config'
local notify = require 'sops.notify'

local M = {}

local function build_env(...)
  local env = {}
  local os_env = vim.loop.os_environ()

  -- Following environment variables
  for _, name in ipairs(config.follow) do
    env[name] = os_env[name]
  end

  local forced = {
    PATH = vim.loop.os_environ()['PATH'],
    HOME = vim.loop.os_homedir(),
  }

  return vim.tbl_extend('force', env, config.env, ..., forced)
end

function M.call_sops(opts)
  local stdout = {}
  local stderr = {}
  local on_success = opts.on_success or function() end
  local on_error = opts.on_error or function() end
  local success_codes = opts.success_codes or { 0 }
  local sync = opts.sync or false

  opts.on_success = nil
  opts.on_error = nil
  opts.success_codes = nil
  opts.sync = nil

  local job_opts = vim.tbl_extend('force', {}, opts, {
    env = build_env(opts.env or {}),
    command = config.binary,

    on_stdout = function(err, data, _job)
      if err then
        notify.error('SOPS: Unable to read file: ' .. vim.inspect(err))
        return
      end
      stdout[#stdout + 1] = data
    end,

    on_stderr = function(err, data, _job)
      if err then
        notify.error('SOPS: Unable to read file: ' .. vim.inspect(err))
        return
      end
      stderr[#stderr + 1] = data
    end,

    on_exit = function(j, code, _signal)
      if not vim.tbl_contains(success_codes, code) then
        vim.schedule(function()
          notify.error('SOPS: Error while decrypting file\n' .. vim.iter(stderr):join('\n'))
          on_error {
            code = code,
            stdout = stdout,
            stderr = stderr,
          }
        end)
        return
      end

      vim.schedule(function()
        on_success {
          stdout = stdout,
          stderr = stderr,
          code = code,
        }
      end)
    end
  })

  local Job = require 'plenary.job'
  local success, job = pcall(Job.new, Job, job_opts)

  if not success then
    notify.error 'SOPS: Unable to call sops.\nIs sops binary installed ?'
    return nil
  end

  if sync then
    job:sync()
  else
    job:start()
  end

  return job
end

function M.read_decrypted_file(file, on_success, on_error)
  local job = M.call_sops {
    args = { '-d', file },
    on_success = function(ctx)
      on_success(ctx.stdout)
    end,
    on_error = function(ctx)
      if on_error then
        on_error(ctx.stderr)
      end
    end,
  }
  return job
end

function M.read_encrypted_file(file, on_success, on_error)
  local job = M.call_sops {
    args = { '-e', file },
    on_success = function(ctx)
      on_success(ctx.stdout)
    end,
    on_error = function(ctx)
      on_error(ctx.stderr)
    end,
  }
  return job
end

return M

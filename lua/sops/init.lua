local config = require 'sops.config'
local api = require 'sops.api'
local cmd = vim.cmd
local fn = vim.fn
local M = {}

local api_methods = {
  'decrypt_buffer',
  'encrypt_buffer',
  'edit',
  'close',
  'toggle',
}

local function load_and_call(modname, name)
  return function(...)
    local mod = require(modname)
    mod[name](...)
  end
end

for _, name in ipairs(api_methods) do
  M[name] = function(...)
    local api = require 'sops.api'
    M[name] = api[name]
    return api[name](...)
  end
end

function setup_events()
  local group_id = vim.api.nvim_create_augroup('Sops', {
    clear = true
  })

  local events = {
    { 'BufReadCmd',  'read_encrypted_file' },
    { 'BufWriteCmd', 'write_encrypted_file' },
  }

  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event[1], {
      pattern = 'sops://*',
      group = group_id,
      callback = load_and_call('sops.events', event[2]),
    })
  end
end

function M.setup(opts)
  setup_events()

  local command = require 'sops.command'
  command.register()
end

-- XXX Maybe a { legendary = true } in setup ? Nice to have.
function M.setup_legendary(opts)
  local legendary = require 'sops.legendary'
  legendary.setup()
end

return M

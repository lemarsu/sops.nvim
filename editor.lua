local uv = vim.loop
local env = uv.os_environ()

local file = _G.arg[1]
local socket = env['SOPS_NVIM_SOCKET']
local bufnr = env['SOPS_NVIM_BUFNR']

-- TODO Exit on missing env

local channel = vim.fn.sockconnect('pipe', socket, { rpc = true })
vim.fn.rpcrequest(channel, 'nvim_exec_lua', [[
  local remote = require 'sops.remote'
  remote.write_sops_file(...)
]], {0 + bufnr, file})

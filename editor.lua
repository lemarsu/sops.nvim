local uv = vim.loop
local env = uv.os_environ()

local function puts(line)
    print(line .. "\n")
end

local function fail(message)
    puts("ERROR: " .. message)
    vim.cmd "cq"
end

local function get_env(name)
  local value = env[name]
  if value == nil then
    fail("missing environment variable " .. name)
  end
  return value
end

local file = _G.arg[1]
if file == nil then
  fail "should be called with an argument"
end

local socket = get_env 'SOPS_NVIM_SOCKET'
local bufnr = get_env 'SOPS_NVIM_BUFNR'

if not pcall(function() bufnr = 0 + bufnr end) then
  fail "SOPS_NVIM_BUFNR should be a number"
end

local channel = vim.fn.sockconnect('pipe', socket, { rpc = true })
vim.fn.rpcrequest(channel, 'nvim_exec_lua', [[
  local remote = require 'sops.remote'
  remote.write_sops_file(...)
]], {bufnr, file})

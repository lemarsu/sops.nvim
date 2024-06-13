local M = {}

local config = {
  binary = 'sops',
  legendary_integration = true,
}

local function get_buf_var(name, default)
  local success, value = pcall(vim.api.nvim_buf_get_var, 0, name)
  return success and value or default
end

local priv = {}
function priv.get_binary()
  return get_buf_var('sops_binary', config.binary)
end

setmetatable(M, {
  __index = function(_, k)
    local fn = priv['get_' .. k]
    return fn and fn() or config[k]
  end,
  __newindex = function(_, k, v)
    local fn = priv['set_' .. k]
    if fn ~= nil then
      fn(v)
      return
    end
    config[k] = v
  end,
  __call = function (_, opts)
    vim.tbl_extend('force', config, opts)
  end,
})

return M

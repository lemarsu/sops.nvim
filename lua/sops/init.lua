local M = {}

setmetatable(M, {
  __index = function (t, k)
    local success, mod = pcall(require, 'sops.' .. k)
    if success then
      t[k] = mod
      return t[k]
    end
  end
})

return M

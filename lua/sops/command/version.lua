return {
  complete = function() end,
  cmd = function()
    local version = require 'sops.version'
    print(string.format('sops.nvim v%s', version()))
  end,
}

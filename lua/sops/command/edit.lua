return {
  complete = function() end,
  cmd = function()
    local api = require 'sops.api'
    api.edit()
  end,
}

return {
  complete = function() end,
  cmd = function()
    local api = require 'sops.api'
    api.decrypt_buffer()
  end,
}

local config = require 'sops.config'

return {
  setup = function()
    if not config.legendary_integration or vim.g.sops_legendary_did_load then
      return
    end
    local success, legendary = pcall(require, 'legendary')
    if success then
      vim.g.sops_legendary_did_load = true
      legendary.itemgroups {
        itemgroup = 'SOPS',
        icon = '',
        description = 'Sops plugin commands',
        commands = {
          { ':Sops decrypt', description = 'Decrypt sops file' },
          { ':Sops encrypt', description = 'Encrypt sops file' },
          { ':Sops edit',    description = 'Edit sops file' },
          { ':Sops close',   description = 'Close sops file' },
          { ':Sops toggle',  description = 'Toggle edit sops file' },
        },
      }
    end
  end,
}

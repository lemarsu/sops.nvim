local config = require 'sops.config'

return {
  setup = function()
    if not config.legendary_integration or vim.g.sops_legendary_did_load then
      return
    end
    local success, legendary = pcall(require, 'legendary')
    if success then
      vim.g.sops_legendary_did_load = true
      legendary.itemgroups({
        itemgroup = 'SOPS',
        icon = '',
        description = 'Sops plugin commands',
        commands = {
          { ':SopsDecrypt',   description = 'Decrypt sops file' },
          { ':SopsEncrypt',   description = 'Encrypt sops file' },
          { ':SopsEdit',      description = 'Edit sops file' },
          { ':SopsEditClose', description = 'Close sops file' },
        },
      })
    end
  end,
}

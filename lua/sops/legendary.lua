return {
  setup = function()
    local success, legendary = pcall(require, 'legendary')
    if success then
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

if vim.g.sops_did_load then
  return
end
vim.g.sops_did_load = true

require('sops').setup()

if vim.g.sops_did_load then
  return
end
vim.g.sops_did_load = true

local function load_and_call(modname, name)
  return function(...)
    local sops = require(modname)
    sops[name](...)
  end
end

local api = vim.api
local commands = {
  { 'SopsDecrypt',   'decrypt_buffer',  'Decrypt sops file' },
  { 'SopsEncrypt',   'encrypt_buffer',  'Encrypt sops file' },
  { 'SopsEdit',      'sops_edit',       'Edit sops file' },
  { 'SopsEditClose', 'sops_edit_close', 'Close sops file' },
}
local events = {
  { 'BufReadCmd',  'read_encrypted_file' },
  { 'BufWriteCmd', 'write_encrypted_file' },
}

for _, c in ipairs(commands) do
  api.nvim_create_user_command(c[1], load_and_call('sops.commands', c[2]), {
    desc = c[3],
  })
end

local group_id = api.nvim_create_augroup("Sops", {
  clear = true
})

for _, event in ipairs(events) do
  api.nvim_create_autocmd(event[1], {
    pattern = 'sops://*',
    group = group_id,
    callback = load_and_call('sops.events', event[2]),
  })
end

local function write_sops_file(bufnr, temp_file)
  local Path = require 'plenary.path'
  local file = Path:new(temp_file)
  local content = vim.tbl_map(
    function(line)
      return line .. "\n"
    end,
    vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  )
  file:write(content, 'w')
end

local M = {
  write_sops_file = write_sops_file,
}

return M

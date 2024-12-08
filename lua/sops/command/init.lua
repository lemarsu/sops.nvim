local M = {}

local command_names = {
  'close',
  'decrypt',
  'edit',
  'encrypt',
  'toggle',
  'version',
}

local commands = {}

local function load_commands()
  if #commands ~= 0 then
    return
  end
  for _, name in ipairs(command_names) do
    commands[name] = require('sops.command.' .. name)
  end
end

local function parse_line(line, cursor_pos)
  local raw_args = vim.split(line, ' +', { trimempty = true })
  local parse_pos = 1
  local args = vim.iter(raw_args):map(function(arg)
    local start, stop = string.find(line, arg, parse_pos, { plain = true })
    parse_pos = stop
    return {
      arg = arg,
      start = start,
      stop = stop,
    }
  end):totable()
  parse_pos = 1
  local arg_idx = 1
  vim.iter(args):find(function(arg)
    if cursor_pos < arg.start then
      arg_idx = arg_idx - 1
      return true
    elseif cursor_pos <= arg.stop then
      return true
    end
    arg_idx = arg_idx + 1
    return false
  end)
  arg_idx = arg_idx < 1 and 1 or arg_idx
  if arg_idx > #args then
    args[#args + 1] = {
      arg = '',
      start = line:len(),
      stop = line:len(),
    }
  end
  return {
    line = line,
    args = args,
    arg_idx = arg_idx,
    pos = cursor_pos,
    in_arg_pos = args[arg_idx] and cursor_pos - args[arg_idx].start + 1,
  }
end
-- print(vim.inspect(parse_line('Sops ', 6)))

local function sops_cmd_complete(arg_lead, cmd_line, cursor_pos)
  load_commands()
  local parsed_line = parse_line(cmd_line, cursor_pos)
  local arg = parsed_line.args[parsed_line.arg_idx]
  if parsed_line.arg_idx == 2 then
    return vim.iter(commands):map(function(name, command)
      return vim.startswith(name, arg.arg) and name or nil
    end):totable()
  elseif parsed_line.arg_idx > 2 then
    local cmd = parsed_line.args[2].arg
    local command = commands[cmd]
    return command and command.complete and command.complete(parsed_line)
  end
end

local function sops_cmd(param)
  load_commands()
  local args = param.fargs
  local cmd = args[1] or 'edit';
  table.remove(args, 1)
  local command = commands[cmd]
  if command then
    command.cmd(args)
  else
    vim.api.nvim_err_writeln(string.format([[No Sops subcommand "%s"]], cmd))
  end
end

function M.register()
  vim.api.nvim_create_user_command('Sops', sops_cmd, {
    nargs = '*',
    complete = sops_cmd_complete
  })
end

return M

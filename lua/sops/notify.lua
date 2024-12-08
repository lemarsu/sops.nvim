local notify = {
  error = function(msg)
    vim.notify(msg, vim.log.levels.ERROR)
  end,
  warn = function(msg)
    vim.notify(msg, vim.log.levels.WARN)
  end,
  info = function(msg)
    vim.notify(msg, vim.log.levels.INFO)
  end,
}

return notify

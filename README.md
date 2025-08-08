# sops.nvim

`sops.nvim` is a plugin to allow you to edit encrypted [sops] file directly from the comfort of [neovim].

You can also encrypt and decrypt files from neovim.

# Installation

## With [lazy.nvim][lazy-nvim]

```lua
{
    'lemarsu/sops.nvim'
}
```

That's it !

# Usage

`sops.nvim` gives you the `Sops` command and the following subcommands:

- `:Sops edit`: edit the current file as if you were calling sops directly.
- `:Sops close`: close a session started with `Sops edit`.
- `:Sops toggle`: close the current edit session if it exists otherwise start a new edit session.
- `:Sops encrypt`: Encrypt the current file with sops.
- `:Sops decrypt`: Decrypt the current file with sops.
- `:Sops version`: Show the current version of `sops.nvim`.

# Configuration

You can configure sops plugin by using `sops.config` module. This can be done before or after loading the plugin.

```lua
local config = require 'sops.config'

-- Set sops binary path
config.binary = '/path/to/sops/binary'

-- If the binary is in the path but it is not named `sops`,
-- you can just specify its name.
config.binary = 'my-sops'

-- Set environment variables for calling sops.
config.env = {
  SOPS_AGE_KEY = '...',
}

-- Declare environment variables followed when calling sops.
-- PATH and HOME are always followed.
config.follow = { 'SOPS_AGE_KEY' }
```

## Configuration using Lazy.nvim

If you want to configure the plugin directly when declaring it in
[lazy.nvim][lazy-nvim], you can configure it using `opts` as shown below:

```lua
{
  -- Sops edit tools
  "lemarsu/sops.nvim",
  opts = function()
    local config = require 'sops.config'
    -- Set sops binary path
    config.binary = '/path/to/sops/binary'

    -- If the binary is in the path but it is not named `sops`,
    -- you can just specify its name.
    config.binary = 'my-sops'

    -- Set environment variables for calling sops.
    config.env = {
      SOPS_AGE_KEY = '...',
    }

    -- Declare environment variables followed when calling sops.
    -- PATH and HOME are always followed.
    config.follow = { 'SOPS_AGE_KEY' }
  end,
}

```

[lazy-nvim]: https://lazy.folke.io/
[neovim]: https://neovim.io
[sops]: https://getsops.io

# sops.nvim

`sops.nvim` is a plugin to allow you to edit encrypted [sops] file directly from the comfort of [neovim].

You can also encrypt and decrypt files from neovim.

# Installation

## With lazy

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

[neovim]: https://neovim.io
[sops]: https://getsops.io

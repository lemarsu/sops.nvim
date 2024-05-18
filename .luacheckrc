std = "min"
exclude_files = { "config/helix/runtime/**/*.lua" }

local fields_ro = { other_fields = true, read_only = true };
local ro = { read_only = true };

files["**/*.lua"] = {
  read_globals = {
    vim = {
      fields = {
        api = fields_ro,
        cmd = fields_ro,
        defer_fn = ro,
        diagnostic = fields_ro,
        fn = fields_ro,
        fs = fields_ro,
        g = fields_ro,
        keymap = fields_ro,
        loop = fields_ro,
        lsp = {
          fields = {
            handlers = fields_ro
          },
          other_fields = true,
          read_only = true,
        },
        notify = ro,
        o = fields_ro,
        opt = fields_ro,
        v = fields_ro,
      },
    },
  },
}

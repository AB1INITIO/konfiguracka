-- nvim-present: a minimal, light, high-contrast Neovim for showing code.
-- Launch with `NVIM_APPNAME=nvim-present nvim file.py`, or pick it in `vv`.

-- Load options
require("config.options")

-- Colourscheme (colors/projector.lua)
vim.cmd.colorscheme("projector")

-- Load mappings (sets <leader>, so it must run before lazy)
require("config.mappings")

-- Autocommands and LSP (K only)
require("config.autocmds")
require("config.lsp")

-- Lazy plugin manager
require("config.lazy")

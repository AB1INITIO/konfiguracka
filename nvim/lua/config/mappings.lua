-- Mappings, few on purpose. Built-ins worth knowing while presenting:
--   K            documentation of the symbol under the cursor (LSP, see config/lsp.lua)
--   [b ]b        previous/next buffer        :e <file>   open a file
--   <C-d> <C-u>  half a page down/up         zt zz zb    put this line at top/middle/bottom
--   <C-o> <C-i>  jump back/forward           gg G        first/last line

local map = vim.keymap.set

-- Map leader to SPACE
vim.g.mapleader = " "

map('n', '<leader>', '<Nop>', { desc = 'Disallow space cursor jump' })

map('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '-', '<Cmd>Explore<CR>',        { desc = 'Browse the directory of the current file' })

map('n', '<leader>n', '<Cmd>set number!<CR>', { desc = 'Toggle line numbers' })

-- Run the current file, or open its language's interpreter, in a terminal
-- panel at the bottom (Ctrl-X closes the output, Ctrl-D quits the interpreter)
map('n', '<leader>r', function() require('custom.run').run() end,  { desc = 'Run current file' })
map('n', '<leader>i', function() require('custom.run').repl() end, { desc = 'Open interpreter' })

-- Close the current buffer but keep the window layout. Takes over <C-x>'s
-- "decrement number". Terminals close with their window (stopping a program
-- that is still running); the interpreter only quits with Ctrl-D.
map('n', '<C-x>', function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].repl then
        return vim.notify('Interpreter: quit it with Ctrl-D')
    end
    if vim.bo[buf].buftype == 'terminal' then
        return vim.api.nvim_buf_delete(buf, { force = true })
    end
    vim.cmd.bprevious()
    if vim.api.nvim_get_current_buf() == buf then vim.cmd.enew() end
    pcall(vim.cmd, 'confirm bdelete ' .. buf)
end, { desc = 'Close current buffer' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Spotlight: dim everything except the code being talked about
map('n', '<leader>f', function() require('custom.spotlight').toggle() end,    { desc = 'Spotlight function under cursor' })
map('x', '<leader>f', function() require('custom.spotlight').selection() end, { desc = 'Spotlight selected lines' })

-- K is the only LSP feature wanted, so drop Neovim's other default LSP
-- mappings (rename, references, code actions, symbols, signature help)
for _, lhs in ipairs({ 'grn', 'grr', 'gri', 'grt', 'gra', 'gO' }) do
    pcall(vim.keymap.del, 'n', lhs)
end
pcall(vim.keymap.del, 'x', 'gra')
pcall(vim.keymap.del, 'i', '<C-s>')

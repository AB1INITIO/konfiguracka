-- Autocommands
local group = vim.api.nvim_create_augroup('present', { clear = true })

-- No automatic comment leaders on new lines. Filetype plugins set
-- 'formatoptions', so this has to run after them.
vim.api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end,
})

-- Paint the terminal's own background (its window padding) to match the
-- light theme, and give the terminal its colour back on exit
vim.api.nvim_create_autocmd({ 'UIEnter', 'ColorScheme' }, {
    group = group,
    callback = function()
        local bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
        if bg then io.write(('\027]11;#%06x\027\\'):format(bg)) end
    end,
})
vim.api.nvim_create_autocmd('UILeave', {
    group = group,
    callback = function() io.write('\027]111\027\\') end,
})

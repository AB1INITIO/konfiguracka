-- LSP is here for one thing: K shows the signature and documentation of the
-- symbol under the cursor. Diagnostics, completion, inlay hints and semantic
-- colours stay off. Server configs live in lsp/<name>.lua.

vim.diagnostic.enable(false)

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        -- Semantic tokens would recolour the code a moment after opening it
        client.server_capabilities.semanticTokensProvider = nil

        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover({ max_width = 80, max_height = 20 })
        end, { buffer = ev.buf, desc = 'Show documentation' })
    end,
})

-- Only start servers that are installed, so a missing one stays quiet
for _, name in ipairs({ 'clangd', 'pyright' }) do
    if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
        vim.lsp.enable(name)
    end
end

-- Highlighting only: no treesitter indentation, folding or selection.
-- More languages: `:TSInstall <lang>`.
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- frozen, but the `main` rewrite needs Neovim 0.12+
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
        ensure_installed = {
            "bash", "c", "cpp", "lua", "markdown", "markdown_inline",
            "python", "query", "vim", "vimdoc",
        },
        highlight = { enable = true },
    },
}

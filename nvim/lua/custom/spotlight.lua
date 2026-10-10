-- spotlight.lua: dim everything except the lines being talked about.
-- toggle() lights the function/class under the cursor (the paragraph when
-- there is none) or, when a spotlight is on, turns it off.
-- selection() lights the visually selected lines.
local M = {}

local ns = vim.api.nvim_create_namespace("spotlight")
vim.api.nvim_set_hl(0, "SpotlightDim", { default = true, link = "Comment" })

-- Innermost multi-line function/method/class/struct around the cursor, as
-- 1-based first and last line. Node type names differ per language, so match
-- on words: function_definition (C, Python), method_declaration (Java), ...
local function scope()
    local ok, node = pcall(vim.treesitter.get_node)
    while ok and node do
        local t = node:type()
        local first, _, last = node:range()
        if last > first and not t:find("declarator")
            and (t:find("function") or t:find("method") or t:find("class") or t:find("struct")) then
            local parent = node:parent() -- Python decorators wrap the definition
            if parent and parent:type() == "decorated_definition" then node = parent end
            first, _, last = node:range()
            return first + 1, last + 1
        end
        node = node:parent()
    end
    -- Fall back to the lines between the surrounding blank lines
    local before, after = vim.fn.search("^\\s*$", "bnW"), vim.fn.search("^\\s*$", "nW")
    return before + 1, after == 0 and vim.fn.line("$") or after - 1
end

function M.clear()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

-- Light lines first..last (1-based, inclusive), dim the rest
function M.show(first, last)
    M.clear()
    local dim = { hl_group = "SpotlightDim", priority = 10000, end_col = 0, strict = false }
    if first > 1 then
        vim.api.nvim_buf_set_extmark(0, ns, 0, 0, vim.tbl_extend("force", dim, { end_row = first - 1 }))
    end
    if last < vim.fn.line("$") then
        vim.api.nvim_buf_set_extmark(0, ns, last, 0, vim.tbl_extend("force", dim, { end_row = vim.fn.line("$") }))
    end
end

function M.toggle()
    if #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0 then
        M.clear()
    else
        M.show(scope())
    end
end

function M.selection()
    local a, b = vim.fn.line("v"), vim.fn.line(".")
    M.show(math.min(a, b), math.max(a, b))
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end

return M

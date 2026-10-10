-- run.lua: a terminal panel at the bottom, for the code in the current buffer.
-- run(): runs the file with the first suitable program on PATH. The program
--   can read input; when it exits, the cursor goes back to the code and the
--   output stays (Ctrl-X or q closes it).
-- repl(): opens the language's interpreter; Ctrl-D quits it and closes the
--   panel.
-- Both start in the file's directory and share one panel: opening either
-- replaces whatever is there, and closing the window deletes it, so no dead
-- terminals pile up.
local M = {}

-- filetype = { programs to try in order, command }
-- In the command, $exe is the program found, $file this file and $bin a
-- temporary executable for compiled languages
local runners = {
    python     = { { "python3", "python" },      "$exe $file" },
    lua        = { { "lua", "luajit" },          "$exe $file" },
    sh         = { { "sh" },                     "$exe $file" },
    bash       = { { "bash" },                   "$exe $file" },
    zsh        = { { "zsh" },                    "$exe $file" },
    javascript = { { "node", "bun" },            "$exe $file" },
    haskell    = { { "runghc", "runhaskell" },   "$exe $file" },
    java       = { { "java" },                   "$exe $file" },
    go         = { { "go" },                     "$exe run $file" },
    c          = { { "cc", "clang", "gcc" },     "$exe -Wall -o $bin $file -lm && $bin" },
    cpp        = { { "c++", "clang++", "g++" },  "$exe -std=c++17 -Wall -o $bin $file && $bin" },
    rust       = { { "rustc" },                  "$exe -o $bin $file && $bin" },
}

-- filetype = { interpreters to try in order, extra arguments }
local repls = {
    python     = { { "python3", "python" } },
    lua        = { { "lua", "luajit" } },
    sh         = { { "sh" } },
    bash       = { { "bash" } },
    zsh        = { { "zsh" } },
    javascript = { { "node" } },
    haskell    = { { "ghci" } },
    java       = { { "jshell" } },
    ruby       = { { "irb" } },
    julia      = { { "julia" } },
    r          = { { "R" }, { "--quiet", "--no-save" } }, -- no "Save workspace?" on Ctrl-D
    elm        = { { "elm" }, { "repl" } },
}

local panel -- buffer of the open panel

local function first_on_path(programs)
    for _, exe in ipairs(programs) do
        if vim.fn.executable(exe) == 1 then return exe end
    end
end

-- Open the panel running cmd in cwd, replacing the previous one
local function open(cmd, cwd, title)
    if panel and vim.api.nvim_buf_is_valid(panel) then
        vim.api.nvim_buf_delete(panel, { force = true }) -- also stops it if still running
    end
    vim.cmd("botright new")
    vim.api.nvim_win_set_height(0, math.max(8, math.floor(vim.o.lines / 3)))
    vim.fn.jobstart(cmd, { term = true, cwd = cwd })
    panel = vim.api.nvim_get_current_buf()
    vim.bo[panel].buflisted = false  -- Keep it out of :ls and [b ]b
    vim.bo[panel].bufhidden = "wipe" -- Closing the window removes it entirely
    vim.wo.winbar = " ▶ " .. title:gsub("%%", "%%%%")
    vim.wo.cursorline = false
    return panel
end

-- Shell command for a file, and its short form for the winbar. It runs in the
-- file's directory, so the bare name keeps compiler messages short.
local function command(file)
    local name = vim.fn.fnamemodify(file, ":t")
    local arg = vim.fn.shellescape(name)
    local runner = runners[vim.bo.filetype]
    if runner then
        local exe = first_on_path(runner[1])
        if not exe then
            return nil, "none of " .. table.concat(runner[1], ", ") .. " is on PATH"
        end
        local vars = { exe = exe, file = arg, bin = vim.fn.shellescape(vim.fn.tempname()) }
        return (runner[2]:gsub("%$(%w+)", vars)), exe .. " " .. name
    end
    -- Anything else with a shebang (#!/usr/bin/env ruby) runs with that
    local shebang = vim.fn.getline(1):match("^#!%s*(.+)")
    if shebang then
        return shebang .. " " .. arg, shebang .. " " .. name
    end
    return nil, "no runner for filetype '" .. vim.bo.filetype .. "'"
end

function M.run()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or vim.bo.buftype ~= "" then
        return vim.notify("Run: save the code to a file first", vim.log.levels.WARN)
    end
    local cmd, title = command(file)
    if not cmd then
        return vim.notify("Run: " .. title, vim.log.levels.WARN)
    end
    vim.cmd("silent update")

    local code = vim.api.nvim_get_current_win()
    local buf = open(cmd, vim.fs.dirname(file), title)
    vim.keymap.set("n", "q", function()
        vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf, desc = "Close output" })

    -- Back to the code once the program exits, leaving its output on screen.
    -- Not when a newer panel replaced this one, or the cursor already left it.
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(function()
                if vim.api.nvim_get_current_buf() == buf and vim.api.nvim_win_is_valid(code) then
                    vim.cmd.stopinsert()
                    vim.api.nvim_set_current_win(code)
                end
            end)
        end,
    })
    vim.cmd.startinsert() -- terminal mode, so the program can read input
end

function M.repl()
    local repl = repls[vim.bo.filetype]
    local exe = repl and first_on_path(repl[1])
    if not exe then
        local why = repl and "none of " .. table.concat(repl[1], ", ") .. " is on PATH"
            or "no interpreter for filetype '" .. vim.bo.filetype .. "'"
        return vim.notify("Interpreter: " .. why, vim.log.levels.WARN)
    end
    local file = vim.api.nvim_buf_get_name(0)
    local cwd = (file ~= "" and vim.bo.buftype == "") and vim.fs.dirname(file) or vim.fn.getcwd()

    local code = vim.api.nvim_get_current_win()
    local buf = open({ exe, unpack(repl[2] or {}) }, cwd, exe .. " · Ctrl-D to quit")
    vim.b[buf].repl = true -- Ctrl-X (config/mappings.lua) leaves it alone
    -- Ctrl-D quits in normal mode too (in terminal mode it reaches the interpreter as is)
    vim.keymap.set("n", "<C-d>", function()
        vim.fn.chansend(vim.bo[buf].channel, "\4")
    end, { buffer = buf, desc = "Quit the interpreter" })

    -- Once it quits, close the panel and go back to the code, unless a newer
    -- panel already replaced this one
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then return end
                local here = vim.api.nvim_get_current_buf() == buf
                if here then vim.cmd.stopinsert() end
                vim.api.nvim_buf_delete(buf, { force = true })
                if here and vim.api.nvim_win_is_valid(code) then
                    vim.api.nvim_set_current_win(code)
                end
            end)
        end,
    })
    vim.cmd.startinsert()
end

return M

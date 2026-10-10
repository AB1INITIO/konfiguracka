-- projector: a light colourscheme for showing code to a room.
--
-- Accessibility rules it follows:
--   * Every syntax colour reaches WCAG AAA (>= 7:1) on the background; UI
--     text (line numbers) reaches AA (>= 4.5:1), borders >= 3:1.
--   * The hues were picked by simulating protanopia, deuteranopia and
--     tritanopia, so they stay apart for colour-blind viewers.
--   * Colour is never the only cue: keywords and function definitions are
--     bold, comments are neutral grey.
--   * Few colours, so code doesn't look noisy. No italics: they are harder
--     to read for people with dyslexia, and smear on projectors.

vim.cmd.highlight('clear')
vim.g.colors_name = 'projector'
vim.o.background = 'light'

local c = {
    bg       = '#FBFAF8', -- warm off-white, gentler than #FFFFFF on a projector
    fg       = '#1C1C1C', -- 16.3:1
    comment  = '#565656', --  7.0:1
    keyword  = '#1A3C94', --  9.5:1 blue, also used for types
    func     = '#8C1D6B', --  8.0:1 reddish purple
    string   = '#1B6130', --  7.2:1 green
    constant = '#953300', --  7.3:1 vermilion: numbers, booleans, constants
    error    = '#A10000', --  8.0:1
    warn     = '#6E4A00', --  7.6:1
    linenr   = '#6B6B6B', --  5.1:1
    border   = '#808080', --  3.5:1 on floats
    dim      = '#A3A3A3', --  2.3:1, the spotlight's deliberately faded text
    line     = '#EDF1F7', -- cursor line
    visual   = '#D3E2F5', -- selection
    search   = '#FFE38A',
    current  = '#F5B83D', -- current search match
    float    = '#F1F0EC', -- floating windows (K hover)
    ui       = '#E6E4DE', -- statusline, inline code
}

local groups = {
    -- Editor
    Normal       = { fg = c.fg, bg = c.bg },
    NormalFloat  = { fg = c.fg, bg = c.float },
    FloatBorder  = { fg = c.border, bg = c.float },
    FloatTitle   = { fg = c.fg, bg = c.float, bold = true },
    Cursor       = { fg = c.bg, bg = c.keyword },
    lCursor      = { link = 'Cursor' },
    CursorLine   = { bg = c.line },
    CursorColumn = { bg = c.line },
    CursorLineNr = { fg = c.fg, bg = c.line, bold = true },
    LineNr       = { fg = c.linenr },
    SignColumn   = { fg = c.linenr },
    FoldColumn   = { fg = c.linenr },
    Folded       = { fg = c.comment, bg = c.float },
    NonText      = { fg = c.dim },
    SpecialKey   = { fg = c.dim },
    Whitespace   = { fg = c.dim },
    EndOfBuffer  = { fg = c.bg },
    Conceal      = { fg = c.comment },
    Visual       = { bg = c.visual },
    Search       = { fg = c.fg, bg = c.search },
    CurSearch    = { fg = c.fg, bg = c.current, bold = true },
    IncSearch    = { link = 'CurSearch' },
    Substitute   = { link = 'Search' },
    MatchParen   = { bg = c.visual, bold = true },
    WinBar       = { fg = c.fg, bg = c.bg, bold = true },
    WinBarNC     = { fg = c.comment, bg = c.bg, bold = true },
    StatusLine   = { fg = c.fg, bg = c.bg }, -- only shown as a divider above splits
    StatusLineNC = { fg = c.fg, bg = c.bg },
    WinSeparator = { fg = c.border },
    TabLine      = { fg = c.comment, bg = c.ui },
    TabLineFill  = { bg = c.ui },
    TabLineSel   = { fg = c.fg, bg = c.bg, bold = true },
    Pmenu        = { fg = c.fg, bg = c.float },
    PmenuSel     = { fg = c.fg, bg = c.visual, bold = true },
    PmenuSbar    = { bg = c.ui },
    PmenuThumb   = { bg = c.border },
    PmenuMatch   = { fg = c.keyword, bold = true },
    Title        = { fg = c.fg, bold = true },
    Directory    = { fg = c.keyword, bold = true },
    ErrorMsg     = { fg = c.error, bold = true },
    WarningMsg   = { fg = c.warn, bold = true },
    ModeMsg      = { fg = c.fg, bold = true },
    MoreMsg      = { fg = c.keyword, bold = true },
    Question     = { fg = c.keyword, bold = true },
    QuickFixLine = { bg = c.visual },
    ColorColumn  = { bg = c.float },
    DiffAdd      = { bg = '#DDF0DF' },
    DiffChange   = { bg = '#E6EDF7' },
    DiffDelete   = { fg = c.error, bg = '#F7E1E1' },
    DiffText     = { bg = '#C7D8F0', bold = true },
    SpellBad     = { undercurl = true, sp = c.error },
    SpellCap     = { undercurl = true, sp = c.warn },
    SpellLocal   = { undercurl = true, sp = c.keyword },
    SpellRare    = { undercurl = true, sp = c.keyword },
    SpotlightDim = { fg = c.dim },

    -- Syntax (legacy groups; treesitter's @groups link to these)
    Comment     = { fg = c.comment },
    Constant    = { fg = c.constant },
    String      = { fg = c.string },
    Character   = { link = 'String' },
    Identifier  = { fg = c.fg },
    Function    = { fg = c.func },
    Statement   = { fg = c.keyword, bold = true },
    PreProc     = { fg = c.keyword, bold = true },
    Type        = { fg = c.keyword },
    Special     = { fg = c.func },
    SpecialChar = { fg = c.string, bold = true },
    Operator    = { fg = c.fg },
    Delimiter   = { fg = c.fg },
    Tag         = { fg = c.keyword },
    Underlined  = { underline = true },
    Error       = { fg = c.error, bold = true },
    Todo        = { fg = c.fg, bg = c.search, bold = true },
    Added       = { fg = c.string },
    Changed     = { fg = c.keyword },
    Removed     = { fg = c.error },

    -- Treesitter: only where the default links aren't what we want
    ['@variable']                   = { fg = c.fg },
    ['@variable.builtin']           = { link = '@variable' },
    ['@variable.parameter.builtin'] = { link = '@variable' },
    ['@module']                     = { link = '@variable' },
    ['@module.builtin']             = { link = '@variable' },
    ['@property']                   = { link = '@variable' },
    ['@function']                   = { fg = c.func, bold = true }, -- definitions
    ['@function.call']              = { link = 'Function' },
    ['@function.method.call']       = { link = 'Function' },
    ['@function.builtin']           = { link = 'Function' },
    ['@function.macro']             = { link = 'Function' },
    ['@attribute']                  = { link = 'Function' },
    ['@attribute.builtin']          = { link = 'Function' },
    ['@constructor']                = { link = 'Type' },
    ['@type.builtin']               = { link = 'Type' },
    ['@constant.builtin']           = { link = 'Constant' },
    ['@string.documentation']       = { link = 'Comment' },
    ['@string.special.path']        = { link = 'String' },
    ['@string.special.url']         = { fg = c.keyword, underline = true },
    ['@punctuation.special']        = { link = 'Delimiter' },
    ['@tag.builtin']                = { link = 'Tag' },
    ['@markup']                     = { fg = c.fg },
    ['@markup.raw']                 = { fg = c.fg, bg = c.ui },
    ['@markup.raw.block']           = { fg = c.fg },
    ['@markup.link']                = { fg = c.keyword, underline = true },
    ['@markup.link.label']          = { fg = c.keyword },
    ['@markup.list']                = { fg = c.keyword },
    ['@markup.quote']               = { link = 'Comment' },

    -- Diagnostics are off in this config, but stay legible if switched on
    DiagnosticError = { fg = c.error },
    DiagnosticWarn  = { fg = c.warn },
    DiagnosticInfo  = { fg = c.keyword },
    DiagnosticHint  = { fg = c.comment },
    DiagnosticOk    = { fg = c.string },
}

for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
end

-- ANSI colours for :terminal (<Space>r output): the 16 of the Alacritty
-- "lectern" theme, so program output looks the same inside and outside
-- Neovim. All >= 5:1, most >= 7:1; "bright" is darker, i.e. stronger.
local ansi = {
    '#1C1C1C', '#9D1824', '#036246', '#8B6101', '#0251B7', '#6F2167', '#03728F', '#626C7A', -- normal
    '#5F6670', '#8E011A', '#01573D', '#795401', '#01469F', '#68015F', '#05637C', '#454C56', -- bright
}
for i, colour in ipairs(ansi) do
    vim.g['terminal_color_' .. (i - 1)] = colour
end

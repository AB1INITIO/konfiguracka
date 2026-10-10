-- Options: show code clearly and do nothing clever
local o = vim.o

-- Layout
o.number       = true               -- Absolute numbers, so the room can follow "line 12"
o.numberwidth  = 4
o.signcolumn   = 'no'               -- Nothing puts signs there
o.cursorline   = true               -- A pointer everyone can see
o.winbar       = ' %f %m'           -- File name on top, like a slide title...
o.laststatus   = 0                  -- ...and no statusline at the bottom
o.statusline   = '%#WinSeparator#'  -- Above a split it is just a thin line
o.ruler        = false
o.fillchars    = 'eob: ,stl:─,stlnc:─' -- No ~ past the end of the file
o.shortmess    = o.shortmess .. 'I' -- No intro screen
o.winborder    = 'rounded'          -- Floats (K hover) get a visible edge
o.guicursor    = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor' -- Cursor colour from the theme

-- Long lines wrap instead of running off the screen
o.wrap         = true
o.linebreak    = true               -- Wrap at word boundaries
o.breakindent  = true               -- Wrapped lines keep their indentation
o.showbreak    = '↪ '
o.smoothscroll = true
o.scrolloff    = 8                  -- Keep 8 lines visible above/below cursor when scrolling

-- Indentation
o.expandtab   = true                -- Convert tabs to spaces
o.tabstop     = 4                   -- Number of spaces a tab counts for
o.shiftwidth  = 4                   -- Number of spaces to use for auto-indenting
o.softtabstop = 4                   -- Number of spaces a tab counts for during editing

-- Nothing that changes or hides code behind your back
o.foldenable = false                -- Every line stays visible
o.swapfile   = false                -- No "swap file exists" prompt mid-talk

-- Search and splits
o.ignorecase = true                 -- Case-insensitive search...
o.smartcase  = true                 -- ...unless the pattern has capitals
o.splitright = true
o.splitbelow = true

-- Files
o.confirm   = true                  -- Ask instead of failing on unsaved changes
o.clipboard = 'unnamedplus'         -- y/p use the system clipboard

-- netrw, the file browser behind `-`
vim.g.netrw_banner = 0

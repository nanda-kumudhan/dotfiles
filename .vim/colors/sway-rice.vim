" Vim color file
" Name: sway-rice

set background=dark
highlight clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'sway-rice'

highlight Normal guifg=#d7dee8 guibg=#000000 ctermfg=253 ctermbg=0
highlight NormalNC guifg=#d7dee8 guibg=#000000 ctermfg=253 ctermbg=0
highlight NormalFloat guifg=#d7dee8 guibg=#11161d ctermfg=253 ctermbg=235
highlight SignColumn guifg=#8a93a0 guibg=#000000 ctermfg=245 ctermbg=0
highlight FoldColumn guifg=#56616f guibg=#000000 ctermfg=240 ctermbg=0
highlight Folded guifg=#8a93a0 guibg=#11161d ctermfg=245 ctermbg=235
highlight LineNr guifg=#56616f guibg=#000000 ctermfg=240 ctermbg=0
highlight CursorLineNr guifg=#f1f5f9 guibg=#11161d gui=bold ctermfg=255 ctermbg=235 cterm=bold
highlight CursorLine guibg=#11161d ctermbg=235
highlight CursorColumn guibg=#11161d ctermbg=235
highlight ColorColumn guibg=#11161d ctermbg=235
highlight Conceal guifg=#8a93a0 guibg=#000000 ctermfg=245 ctermbg=0
highlight EndOfBuffer guifg=#000000 guibg=#000000 ctermfg=0 ctermbg=0
highlight NonText guifg=#2f4054 guibg=#000000 ctermfg=238 ctermbg=0
highlight SpecialKey guifg=#2f4054 guibg=#000000 ctermfg=238 ctermbg=0
highlight Directory guifg=#7aa2e3 guibg=#000000 gui=bold ctermfg=110 ctermbg=0 cterm=bold
highlight Title guifg=#f1f5f9 gui=bold ctermfg=255 cterm=bold

highlight Cursor guifg=#000000 guibg=#d7dee8 ctermfg=0 ctermbg=253
highlight lCursor guifg=#000000 guibg=#d7dee8 ctermfg=0 ctermbg=253
highlight TermCursor guifg=#000000 guibg=#d7dee8 ctermfg=0 ctermbg=253
highlight TermCursorNC guifg=#8a93a0 guibg=#1c2733 ctermfg=245 ctermbg=236

highlight Visual guifg=#f1f5f9 guibg=#1c2733 ctermfg=255 ctermbg=236
highlight VisualNOS guifg=#f1f5f9 guibg=#1c2733 ctermfg=255 ctermbg=236
highlight Search guifg=#000000 guibg=#c9a45f ctermfg=0 ctermbg=179
highlight IncSearch guifg=#000000 guibg=#d19a66 gui=bold ctermfg=0 ctermbg=173 cterm=bold
highlight MatchParen guifg=#f1f5f9 guibg=#1c2733 gui=bold ctermfg=255 ctermbg=236 cterm=bold

highlight Pmenu guifg=#d7dee8 guibg=#11161d ctermfg=253 ctermbg=235
highlight PmenuSel guifg=#f1f5f9 guibg=#1c2733 gui=bold ctermfg=255 ctermbg=236 cterm=bold
highlight PmenuSbar guibg=#11161d ctermbg=235
highlight PmenuThumb guibg=#2f4054 ctermbg=238
highlight WildMenu guifg=#f1f5f9 guibg=#1c2733 gui=bold ctermfg=255 ctermbg=236 cterm=bold

highlight StatusLine guifg=#d7dee8 guibg=#11161d ctermfg=253 ctermbg=235
highlight StatusLineNC guifg=#8a93a0 guibg=#000000 ctermfg=245 ctermbg=0
highlight StatusLineTerm guifg=#d7dee8 guibg=#11161d ctermfg=253 ctermbg=235
highlight StatusLineTermNC guifg=#8a93a0 guibg=#000000 ctermfg=245 ctermbg=0
highlight TabLine guifg=#8a93a0 guibg=#11161d ctermfg=245 ctermbg=235
highlight TabLineFill guifg=#8a93a0 guibg=#000000 ctermfg=245 ctermbg=0
highlight TabLineSel guifg=#f1f5f9 guibg=#1c2733 gui=bold ctermfg=255 ctermbg=236 cterm=bold
highlight VertSplit guifg=#2f4054 guibg=#000000 ctermfg=238 ctermbg=0
highlight WinSeparator guifg=#2f4054 guibg=#000000 ctermfg=238 ctermbg=0

highlight SwayRiceStatusAccent guifg=#000000 guibg=#7aa2e3 gui=bold ctermfg=0 ctermbg=110 cterm=bold
highlight SwayRiceStatusFile guifg=#d7dee8 guibg=#11161d ctermfg=253 ctermbg=235
highlight SwayRiceStatusMuted guifg=#8a93a0 guibg=#11161d ctermfg=245 ctermbg=235
highlight SwayRiceStatusIcon guifg=#7aa2e3 guibg=#11161d gui=bold ctermfg=110 ctermbg=235 cterm=bold

highlight Question guifg=#8fbf7f gui=bold ctermfg=108 cterm=bold
highlight MoreMsg guifg=#8fbf7f gui=bold ctermfg=108 cterm=bold
highlight ModeMsg guifg=#8a93a0 ctermfg=245
highlight WarningMsg guifg=#c9a45f ctermfg=179
highlight ErrorMsg guifg=#d76f7b gui=bold ctermfg=167 cterm=bold

highlight Comment guifg=#8a93a0 gui=italic ctermfg=245
highlight Constant guifg=#7aa2e3 ctermfg=110
highlight String guifg=#8fbf7f ctermfg=108
highlight Character guifg=#8fbf7f ctermfg=108
highlight Number guifg=#c9a45f ctermfg=179
highlight Boolean guifg=#c9a45f ctermfg=179
highlight Float guifg=#c9a45f ctermfg=179
highlight Identifier guifg=#d7dee8 ctermfg=253
highlight Function guifg=#7aa2e3 ctermfg=110
highlight Statement guifg=#d76f7b ctermfg=167
highlight Conditional guifg=#d76f7b ctermfg=167
highlight Repeat guifg=#d76f7b ctermfg=167
highlight Label guifg=#b58bdc ctermfg=140
highlight Operator guifg=#d76f7b ctermfg=167
highlight Keyword guifg=#d76f7b ctermfg=167
highlight Exception guifg=#d76f7b ctermfg=167
highlight PreProc guifg=#b58bdc ctermfg=140
highlight Include guifg=#6fb7c8 ctermfg=109
highlight Define guifg=#b58bdc ctermfg=140
highlight Macro guifg=#b58bdc ctermfg=140
highlight PreCondit guifg=#b58bdc ctermfg=140
highlight Type guifg=#b58bdc ctermfg=140
highlight StorageClass guifg=#b58bdc ctermfg=140
highlight Structure guifg=#b58bdc ctermfg=140
highlight Typedef guifg=#b58bdc ctermfg=140
highlight Special guifg=#6fb7c8 ctermfg=109
highlight SpecialChar guifg=#6fb7c8 ctermfg=109
highlight Tag guifg=#7aa2e3 ctermfg=110
highlight Delimiter guifg=#8a93a0 ctermfg=245
highlight SpecialComment guifg=#8a93a0 gui=italic ctermfg=245
highlight Debug guifg=#d19a66 ctermfg=173
highlight Underlined guifg=#7aa2e3 gui=underline ctermfg=110 cterm=underline
highlight Ignore guifg=#56616f ctermfg=240
highlight Error guifg=#d76f7b guibg=#000000 gui=bold ctermfg=167 ctermbg=0 cterm=bold
highlight Todo guifg=#c9a45f guibg=#1c2733 gui=bold ctermfg=179 ctermbg=236 cterm=bold

highlight DiffAdd guifg=#8fbf7f guibg=#172519 ctermfg=108 ctermbg=22
highlight DiffChange guifg=#7aa2e3 guibg=#172433 ctermfg=110 ctermbg=24
highlight DiffDelete guifg=#d76f7b guibg=#2a1518 ctermfg=167 ctermbg=52
highlight DiffText guifg=#f1f5f9 guibg=#26394c gui=bold ctermfg=255 ctermbg=24 cterm=bold
highlight Added guifg=#8fbf7f ctermfg=108
highlight Changed guifg=#7aa2e3 ctermfg=110
highlight Removed guifg=#d76f7b ctermfg=167

highlight SpellBad guisp=#d76f7b gui=undercurl cterm=underline
highlight SpellCap guisp=#7aa2e3 gui=undercurl cterm=underline
highlight SpellLocal guisp=#6fb7c8 gui=undercurl cterm=underline
highlight SpellRare guisp=#b58bdc gui=undercurl cterm=underline

highlight! link htmlTag Tag
highlight! link htmlEndTag Tag
highlight! link htmlTagName Tag
highlight! link markdownHeadingDelimiter Title
highlight! link markdownCode String
highlight! link markdownUrl Underlined

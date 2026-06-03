vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "sway-rice"
vim.o.background = "dark"

local p = {
  bg = "#000000",
  surface = "#11161d",
  surface_strong = "#1c2733",
  separator = "#2f4054",
  fg = "#d7dee8",
  dim = "#8a93a0",
  muted = "#56616f",
  urgent = "#f1f5f9",
  red = "#d76f7b",
  orange = "#aaaaaa",
  yellow = "#d0d0d0",
  green = "#8fbf7f",
  blue = "#7aa2e3",
  purple = "#b58bdc",
  cyan = "#6fb7c8",
  black = "#000000",
  diff_add = "#172519",
  diff_change = "#172433",
  diff_delete = "#2a1518",
  diff_text = "#26394c",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

hi("Normal", { fg = p.fg, bg = p.bg })
hi("NormalNC", { fg = p.fg, bg = p.bg })
hi("NormalFloat", { fg = p.fg, bg = p.surface })
hi("FloatBorder", { fg = p.separator, bg = p.surface })
hi("FloatTitle", { fg = p.urgent, bg = p.surface, bold = true })
hi("WinSeparator", { fg = p.separator, bg = p.bg })
hi("SignColumn", { fg = p.dim, bg = p.bg })
hi("FoldColumn", { fg = p.muted, bg = p.bg })
hi("Folded", { fg = p.dim, bg = p.surface })
hi("LineNr", { fg = p.muted, bg = p.bg })
hi("CursorLineNr", { fg = p.urgent, bg = p.surface, bold = true })
hi("CursorLine", { bg = p.surface })
hi("CursorColumn", { bg = p.surface })
hi("ColorColumn", { bg = p.surface })
hi("Conceal", { fg = p.dim, bg = p.bg })
hi("EndOfBuffer", { fg = p.bg, bg = p.bg })
hi("NonText", { fg = p.separator, bg = p.bg })
hi("Whitespace", { fg = p.separator, bg = p.bg })
hi("SpecialKey", { fg = p.separator, bg = p.bg })
hi("Directory", { fg = p.blue, bg = p.bg, bold = true })
hi("Title", { fg = p.urgent, bold = true })

hi("Cursor", { fg = p.bg, bg = p.fg })
hi("lCursor", { fg = p.bg, bg = p.fg })
hi("TermCursor", { fg = p.bg, bg = p.fg })
hi("TermCursorNC", { fg = p.dim, bg = p.surface_strong })

hi("Visual", { fg = p.urgent, bg = p.surface_strong })
hi("VisualNOS", { fg = p.urgent, bg = p.surface_strong })
hi("Search", { fg = p.bg, bg = p.yellow })
hi("IncSearch", { fg = p.bg, bg = p.orange })
hi("CurSearch", { fg = p.bg, bg = p.orange, bold = true })
hi("MatchParen", { fg = p.urgent, bg = p.surface_strong, bold = true })

hi("Pmenu", { fg = p.fg, bg = p.surface })
hi("PmenuSel", { fg = p.urgent, bg = p.surface_strong, bold = true })
hi("PmenuSbar", { bg = p.surface })
hi("PmenuThumb", { bg = p.separator })
hi("WildMenu", { fg = p.urgent, bg = p.surface_strong, bold = true })

hi("StatusLine", { fg = p.fg, bg = p.surface })
hi("StatusLineNC", { fg = p.dim, bg = p.bg })
hi("TabLine", { fg = p.dim, bg = p.surface })
hi("TabLineFill", { fg = p.dim, bg = p.bg })
hi("TabLineSel", { fg = p.urgent, bg = p.surface_strong, bold = true })
hi("WinBar", { fg = p.dim, bg = p.bg })
hi("WinBarNC", { fg = p.muted, bg = p.bg })

hi("SwayRiceStatusFile", { fg = p.fg, bg = p.surface })
hi("SwayRiceStatusMuted", { fg = p.dim, bg = p.surface })
hi("SwayRiceStatusIcon", { fg = p.blue, bg = p.surface, bold = true })
hi("SwayRiceStatusModeNormal", { fg = p.bg, bg = p.blue, bold = true })
hi("SwayRiceStatusModeInsert", { fg = p.bg, bg = p.green, bold = true })
hi("SwayRiceStatusModeVisual", { fg = p.bg, bg = p.yellow, bold = true })
hi("SwayRiceStatusModeReplace", { fg = p.bg, bg = p.red, bold = true })
hi("SwayRiceStatusModeCommand", { fg = p.bg, bg = p.purple, bold = true })
hi("SwayRiceStatusModeTerminal", { fg = p.bg, bg = p.cyan, bold = true })
hi("SwayRiceWinbar", { fg = p.dim, bg = p.bg })
hi("SwayRiceWinbarMuted", { fg = p.muted, bg = p.bg })

hi("Question", { fg = p.green, bold = true })
hi("MoreMsg", { fg = p.green, bold = true })
hi("ModeMsg", { fg = p.dim })
hi("WarningMsg", { fg = p.yellow })
hi("ErrorMsg", { fg = p.red, bold = true })

hi("Comment", { fg = p.dim, italic = true })
hi("Constant", { fg = p.blue })
hi("String", { fg = p.green })
hi("Character", { fg = p.green })
hi("Number", { fg = p.yellow })
hi("Boolean", { fg = p.yellow })
hi("Float", { fg = p.yellow })
hi("Identifier", { fg = p.fg })
hi("Function", { fg = p.blue })
hi("Statement", { fg = p.red })
hi("Conditional", { fg = p.red })
hi("Repeat", { fg = p.red })
hi("Label", { fg = p.purple })
hi("Operator", { fg = p.red })
hi("Keyword", { fg = p.red })
hi("Exception", { fg = p.red })
hi("PreProc", { fg = p.purple })
hi("Include", { fg = p.cyan })
hi("Define", { fg = p.purple })
hi("Macro", { fg = p.purple })
hi("PreCondit", { fg = p.purple })
hi("Type", { fg = p.purple })
hi("StorageClass", { fg = p.purple })
hi("Structure", { fg = p.purple })
hi("Typedef", { fg = p.purple })
hi("Special", { fg = p.cyan })
hi("SpecialChar", { fg = p.cyan })
hi("Tag", { fg = p.blue })
hi("Delimiter", { fg = p.dim })
hi("SpecialComment", { fg = p.dim, italic = true })
hi("Debug", { fg = p.orange })
hi("Underlined", { fg = p.blue, underline = true })
hi("Ignore", { fg = p.muted })
hi("Error", { fg = p.red, bg = p.bg, bold = true })
hi("Todo", { fg = p.yellow, bg = p.surface_strong, bold = true })

hi("DiagnosticError", { fg = p.red })
hi("DiagnosticWarn", { fg = p.yellow })
hi("DiagnosticInfo", { fg = p.cyan })
hi("DiagnosticHint", { fg = p.dim })
hi("DiagnosticOk", { fg = p.green })
hi("DiagnosticSignError", { fg = p.red, bg = p.bg })
hi("DiagnosticSignWarn", { fg = p.yellow, bg = p.bg })
hi("DiagnosticSignInfo", { fg = p.cyan, bg = p.bg })
hi("DiagnosticSignHint", { fg = p.dim, bg = p.bg })
hi("DiagnosticVirtualTextError", { fg = p.red, bg = p.surface })
hi("DiagnosticVirtualTextWarn", { fg = p.yellow, bg = p.surface })
hi("DiagnosticVirtualTextInfo", { fg = p.cyan, bg = p.surface })
hi("DiagnosticVirtualTextHint", { fg = p.dim, bg = p.surface })
hi("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hi("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hi("DiagnosticUnderlineInfo", { sp = p.cyan, undercurl = true })
hi("DiagnosticUnderlineHint", { sp = p.dim, undercurl = true })

hi("DiffAdd", { fg = p.green, bg = p.diff_add })
hi("DiffChange", { fg = p.blue, bg = p.diff_change })
hi("DiffDelete", { fg = p.red, bg = p.diff_delete })
hi("DiffText", { fg = p.urgent, bg = p.diff_text, bold = true })
hi("Added", { fg = p.green })
hi("Changed", { fg = p.blue })
hi("Removed", { fg = p.red })

hi("GitSignsAdd", { fg = p.green, bg = p.bg })
hi("GitSignsChange", { fg = p.blue, bg = p.bg })
hi("GitSignsDelete", { fg = p.red, bg = p.bg })

local links = {
  ["@annotation"] = "PreProc",
  ["@attribute"] = "PreProc",
  ["@boolean"] = "Boolean",
  ["@character"] = "Character",
  ["@comment"] = "Comment",
  ["@conditional"] = "Conditional",
  ["@constant"] = "Constant",
  ["@constant.builtin"] = "Special",
  ["@constant.macro"] = "Macro",
  ["@constructor"] = "Special",
  ["@diff.plus"] = "Added",
  ["@diff.minus"] = "Removed",
  ["@diff.delta"] = "Changed",
  ["@error"] = "Error",
  ["@exception"] = "Exception",
  ["@field"] = "Identifier",
  ["@float"] = "Float",
  ["@function"] = "Function",
  ["@function.builtin"] = "Special",
  ["@function.macro"] = "Macro",
  ["@include"] = "Include",
  ["@keyword"] = "Keyword",
  ["@keyword.function"] = "Keyword",
  ["@keyword.operator"] = "Operator",
  ["@label"] = "Label",
  ["@method"] = "Function",
  ["@namespace"] = "Identifier",
  ["@none"] = "Normal",
  ["@number"] = "Number",
  ["@operator"] = "Operator",
  ["@parameter"] = "Identifier",
  ["@property"] = "Identifier",
  ["@punctuation.bracket"] = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.special"] = "Special",
  ["@repeat"] = "Repeat",
  ["@string"] = "String",
  ["@string.escape"] = "SpecialChar",
  ["@string.regex"] = "SpecialChar",
  ["@symbol"] = "Constant",
  ["@tag"] = "Tag",
  ["@tag.attribute"] = "Identifier",
  ["@tag.delimiter"] = "Delimiter",
  ["@text"] = "Normal",
  ["@text.danger"] = "Error",
  ["@text.emphasis"] = "Normal",
  ["@text.literal"] = "String",
  ["@text.reference"] = "Underlined",
  ["@text.strong"] = "Title",
  ["@text.title"] = "Title",
  ["@text.todo"] = "Todo",
  ["@text.uri"] = "Underlined",
  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Special",
  ["@lsp.type.class"] = "Type",
  ["@lsp.type.decorator"] = "PreProc",
  ["@lsp.type.enum"] = "Type",
  ["@lsp.type.enumMember"] = "Constant",
  ["@lsp.type.function"] = "Function",
  ["@lsp.type.interface"] = "Type",
  ["@lsp.type.keyword"] = "Keyword",
  ["@lsp.type.macro"] = "Macro",
  ["@lsp.type.method"] = "Function",
  ["@lsp.type.namespace"] = "Identifier",
  ["@lsp.type.parameter"] = "Identifier",
  ["@lsp.type.property"] = "Identifier",
  ["@lsp.type.struct"] = "Type",
  ["@lsp.type.type"] = "Type",
  ["@lsp.type.variable"] = "Identifier",
}

for group, link in pairs(links) do
  hi(group, { link = link })
end

hi("TelescopeBorder", { fg = p.separator, bg = p.surface })
hi("TelescopeNormal", { fg = p.fg, bg = p.surface })
hi("TelescopePromptNormal", { fg = p.fg, bg = p.surface_strong })
hi("TelescopePromptBorder", { fg = p.separator, bg = p.surface_strong })
hi("TelescopePromptTitle", { fg = p.bg, bg = p.blue, bold = true })
hi("TelescopePreviewTitle", { fg = p.bg, bg = p.green, bold = true })
hi("TelescopeResultsTitle", { fg = p.bg, bg = p.purple, bold = true })
hi("TelescopeSelection", { fg = p.urgent, bg = p.surface_strong, bold = true })
hi("TelescopeMatching", { fg = p.yellow, bold = true })

hi("BlinkCmpMenu", { fg = p.fg, bg = p.surface })
hi("BlinkCmpMenuSelection", { fg = p.urgent, bg = p.surface_strong, bold = true })
hi("BlinkCmpLabelMatch", { fg = p.blue, bold = true })
hi("BlinkCmpGhostText", { fg = p.muted })

hi("NvimTreeNormal", { fg = p.fg, bg = p.bg })
hi("NvimTreeEndOfBuffer", { fg = p.bg, bg = p.bg })
hi("NvimTreeFolderName", { fg = p.blue })
hi("NvimTreeOpenedFolderName", { fg = p.urgent, bold = true })
hi("NvimTreeRootFolder", { fg = p.purple, bold = true })
hi("NvimTreeGitDirty", { fg = p.yellow })
hi("NvimTreeGitNew", { fg = p.green })
hi("NvimTreeGitDeleted", { fg = p.red })
hi("WhichKey", { fg = p.blue, bold = true })
hi("WhichKeyGroup", { fg = p.purple })
hi("WhichKeyDesc", { fg = p.fg })
hi("WhichKeySeparator", { fg = p.muted })
hi("WhichKeyFloat", { bg = p.surface })
hi("LazyNormal", { fg = p.fg, bg = p.surface })
hi("LazyButton", { fg = p.fg, bg = p.surface_strong })
hi("LazyButtonActive", { fg = p.bg, bg = p.blue, bold = true })
hi("MasonNormal", { fg = p.fg, bg = p.surface })
hi("TroubleNormal", { fg = p.fg, bg = p.bg })
hi("TroubleText", { fg = p.fg })
hi("TroubleCount", { fg = p.purple, bg = p.surface_strong, bold = true })

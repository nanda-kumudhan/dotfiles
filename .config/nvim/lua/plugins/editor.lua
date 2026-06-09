return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "sway-rice",
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = false },
      scroll = { enabled = false },
      indent = { enabled = true },
      picker = {
        hidden = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = false,
          },
        },
      },
      styles = {
        notification = {
          wo = { wrap = true },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = "",
        section_separators = "",
        globalstatus = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}

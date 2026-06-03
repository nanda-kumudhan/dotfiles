vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 28
vim.g.netrw_localcopydircmd = "cp -r"

local opt = vim.opt

opt.termguicolors = true
opt.background = "dark"
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backspace = { "indent", "eol", "start" }

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false
opt.showcmd = false
opt.cmdheight = 1
opt.laststatus = 3
opt.showtabline = 2
opt.pumheight = 12
opt.splitbelow = true
opt.splitright = true
opt.shortmess:append("c")
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
  vert = "│",
  diff = "╱",
}

if vim.fn.exists("&winborder") == 1 then
  opt.winborder = "single"
end

opt.expandtab = true
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.grepprg = "rg --vimgrep --smart-case --hidden"
opt.grepformat = "%f:%l:%c:%m"

opt.hidden = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

pcall(vim.cmd, "colorscheme sway-rice")

local mode_labels = {
  n = { "NORMAL", "SwayRiceStatusModeNormal" },
  no = { "OP", "SwayRiceStatusModeNormal" },
  nov = { "OP", "SwayRiceStatusModeNormal" },
  noV = { "OP", "SwayRiceStatusModeNormal" },
  ["no\22"] = { "OP", "SwayRiceStatusModeNormal" },
  niI = { "NORMAL", "SwayRiceStatusModeNormal" },
  niR = { "NORMAL", "SwayRiceStatusModeNormal" },
  niV = { "NORMAL", "SwayRiceStatusModeNormal" },
  i = { "INSERT", "SwayRiceStatusModeInsert" },
  ic = { "INSERT", "SwayRiceStatusModeInsert" },
  ix = { "INSERT", "SwayRiceStatusModeInsert" },
  v = { "VISUAL", "SwayRiceStatusModeVisual" },
  V = { "V-LINE", "SwayRiceStatusModeVisual" },
  ["\22"] = { "V-BLOCK", "SwayRiceStatusModeVisual" },
  s = { "SELECT", "SwayRiceStatusModeVisual" },
  S = { "S-LINE", "SwayRiceStatusModeVisual" },
  ["\19"] = { "S-BLOCK", "SwayRiceStatusModeVisual" },
  R = { "REPLACE", "SwayRiceStatusModeReplace" },
  Rc = { "REPLACE", "SwayRiceStatusModeReplace" },
  Rv = { "V-REPLACE", "SwayRiceStatusModeReplace" },
  c = { "COMMAND", "SwayRiceStatusModeCommand" },
  cv = { "EX", "SwayRiceStatusModeCommand" },
  ce = { "EX", "SwayRiceStatusModeCommand" },
  r = { "PROMPT", "SwayRiceStatusModeCommand" },
  rm = { "MORE", "SwayRiceStatusModeCommand" },
  ["r?"] = { "CONFIRM", "SwayRiceStatusModeCommand" },
  t = { "TERM", "SwayRiceStatusModeTerminal" },
}

function _G.SwayRiceStatusline()
  local current_mode = vim.fn.mode(1)
  local mode = mode_labels[current_mode] or { current_mode:upper(), "SwayRiceStatusModeNormal" }

  return table.concat({
    "%#",
    mode[2],
    "# ",
    mode[1],
    " ",
    "%#SwayRiceStatusIcon#  ",
    "%#SwayRiceStatusFile#%<%f ",
    "%#SwayRiceStatusMuted#%m%r%h%w",
    "%=",
    "%#SwayRiceStatusMuted# 󰈙 %y ",
    "%#SwayRiceStatusFile#  %l  %c ",
    "%#SwayRiceStatusMuted#%p%% ",
  })
end

opt.statusline = "%!v:lua.SwayRiceStatusline()"

if vim.fn.has("nvim-0.8") == 1 then
  opt.winbar = "%#SwayRiceWinbar# %f%=%#SwayRiceWinbarMuted# %m%r "
end

local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_bootstrap_failed = false

-- Public plugin installs should not inherit the global GitHub SSH rewrite.
vim.env.GIT_CONFIG_GLOBAL = "/dev/null"

if not uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    lazy_bootstrap_failed = true
    vim.notify("Could not install lazy.nvim:\n" .. result, vim.log.levels.ERROR)
  end
end

if not lazy_bootstrap_failed then
  opt.rtp:prepend(lazypath)
end

local function setup_plugins()
  local ok, lazy = pcall(require, "lazy")

  if not ok then
    return
  end

  lazy.setup({
    {
      "nvim-tree/nvim-web-devicons",
      lazy = true,
    },
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
      opts = {
        disable_netrw = false,
        hijack_netrw = true,
        view = {
          width = 32,
          side = "left",
          preserve_window_proportions = true,
        },
        renderer = {
          highlight_git = true,
          indent_markers = { enable = true },
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "",
                arrow_open = "",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        signs = {
          add = { text = "" },
          change = { text = "" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "" },
          untracked = { text = "" },
        },
        current_line_blame = false,
        preview_config = {
          border = "single",
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          if not gs then
            return
          end

          vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, silent = true, desc = "Preview git hunk" })
          vim.keymap.set("n", "<leader>gb", function()
            gs.blame_line({ full = true })
          end, { buffer = bufnr, silent = true, desc = "Git blame line" })
        end,
      },
    },
    {
      "nvim-lua/plenary.nvim",
      lazy = true,
    },
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "Telescope",
      opts = {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
      },
    },
    {
      "saghen/blink.cmp",
      version = "1.*",
      lazy = false,
      opts = {
        keymap = { preset = "default" },
        appearance = {
          nerd_font_variant = "mono",
        },
        completion = {
          documentation = {
            auto_show = false,
            window = { border = "single" },
          },
          menu = { border = "single" },
          ghost_text = { enabled = true },
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "lua" },
        cmdline = { enabled = false },
      },
      opts_extend = { "sources.default" },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      opts = {
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javadoc",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "rust",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        highlight = { enable = true },
        indent = { enable = true },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    {
      "mason-org/mason.nvim",
      opts = {
        ui = {
          border = "single",
          icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
          },
        },
      },
    },
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      dependencies = { "mason-org/mason.nvim" },
      opts = {
        ensure_installed = {
          "lua-language-server",
          "pyright",
          "typescript-language-server",
          "bash-language-server",
          "json-lsp",
          "yaml-language-server",
          "html-lsp",
          "css-lsp",
          "marksman",
          "jdtls",
          "google-java-format",
          "java-debug-adapter",
          "java-test",
          "ruff",
          "shellcheck",
          "eslint_d",
          "prettier",
          "stylua",
          "shfmt",
        },
        run_on_start = true,
        start_delay = 3000,
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = { "mason-org/mason.nvim" },
      config = function()
        if not vim.lsp or not vim.lsp.enable then
          return
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()

        if package.loaded["blink.cmp"] then
          local blink_ok, blink = pcall(require, "blink.cmp")

          if blink_ok and blink.get_lsp_capabilities then
            capabilities = blink.get_lsp_capabilities(capabilities)
          end
        end

        vim.lsp.config("*", {
          capabilities = capabilities,
        })

        vim.lsp.config("lua_ls", {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        })

        vim.lsp.enable({
          "lua_ls",
          "pyright",
          "ts_ls",
          "bashls",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "marksman",
        })
      end,
    },
    {
      "mfussenegger/nvim-dap",
      lazy = true,
      keys = {
        {
          "<leader>db",
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "Toggle breakpoint",
        },
        {
          "<leader>dc",
          function()
            require("dap").continue()
          end,
          desc = "Debug continue",
        },
        {
          "<leader>do",
          function()
            require("dap").step_over()
          end,
          desc = "Debug step over",
        },
        {
          "<leader>di",
          function()
            require("dap").step_into()
          end,
          desc = "Debug step into",
        },
        {
          "<leader>dt",
          function()
            require("dap").terminate()
          end,
          desc = "Debug terminate",
        },
        {
          "<leader>dr",
          function()
            require("dap").repl.toggle()
          end,
          desc = "Debug REPL",
        },
      },
      config = function()
        local dap = require("dap")
        dap.defaults.fallback.terminal_win_cmd = "botright 12split new"
      end,
    },
    {
      "mfussenegger/nvim-jdtls",
      ft = "java",
      dependencies = { "mfussenegger/nvim-dap" },
      config = function()
        local function glob(pattern)
          local matches = vim.fn.glob(pattern, true, true)

          if type(matches) == "table" then
            return matches
          end

          return {}
        end

        local function java_bundles()
          local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
          local bundles = glob(mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
          local test_bundles = glob(mason_packages .. "/java-test/extension/server/*.jar")
          local excluded = {
            ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
            ["jacocoagent.jar"] = true,
          }

          for _, jar in ipairs(test_bundles) do
            if not excluded[vim.fn.fnamemodify(jar, ":t")] then
              table.insert(bundles, jar)
            end
          end

          return bundles
        end

        local function start_java_lsp()
          local ok_jdtls, jdtls = pcall(require, "jdtls")

          if not ok_jdtls then
            return
          end

          local jdtls_cmd = vim.fn.exepath("jdtls")

          if jdtls_cmd == "" then
            jdtls_cmd = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
          end

          if vim.fn.executable(jdtls_cmd) ~= 1 then
            vim.notify("Install jdtls with :MasonToolsInstall before using Java LSP", vim.log.levels.WARN)
            return
          end

          local root_dir = vim.fs.root(0, {
            "gradlew",
            "mvnw",
            "pom.xml",
            "build.gradle",
            "build.gradle.kts",
            "settings.gradle",
            "settings.gradle.kts",
            ".git",
          }) or vim.fn.getcwd()
          local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
          local workspace_dir = vim.fn.stdpath("state") .. "/jdtls-workspaces/" .. project_name
          local bundles = java_bundles()

          jdtls.start_or_attach({
            name = "jdtls",
            cmd = { jdtls_cmd, "-data", workspace_dir },
            root_dir = root_dir,
            settings = {
              java = {
                configuration = {
                  updateBuildConfiguration = "interactive",
                },
                sources = {
                  organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                  },
                },
              },
            },
            init_options = {
              bundles = bundles,
            },
          })

          if #bundles > 0 then
            pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
          end
        end

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("SwayRiceJava", { clear = true }),
          pattern = "java",
          callback = start_java_lsp,
        })

        if vim.bo.filetype == "java" then
          start_java_lsp()
        end
      end,
    },
    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          markdown = { "prettier" },
          java = { "google-java-format" },
        },
        format_on_save = {
          timeout_ms = 1200,
          lsp_format = "fallback",
        },
      },
    },
    {
      "mfussenegger/nvim-lint",
      event = { "BufReadPost", "BufWritePost", "InsertLeave" },
      config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
          python = { "ruff" },
          sh = { "shellcheck" },
          bash = { "shellcheck" },
          zsh = { "shellcheck" },
          javascript = { "eslint_d" },
          typescript = { "eslint_d" },
          javascriptreact = { "eslint_d" },
          typescriptreact = { "eslint_d" },
        }

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
          group = vim.api.nvim_create_augroup("SwayRiceLint", { clear = true }),
          callback = function()
            lint.try_lint()
          end,
        })
      end,
    },
    {
      "folke/trouble.nvim",
      cmd = "Trouble",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix diagnostics" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location diagnostics" },
      },
      opts = {
        auto_close = true,
      },
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {
        check_ts = true,
        disable_filetype = { "TelescopePrompt" },
      },
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        delay = 350,
      },
    },
  }, {
    checker = {
      enabled = true,
      notify = false,
    },
    ui = {
      border = "single",
    },
    install = {
      colorscheme = { "sway-rice" },
    },
  })
end

setup_plugins()

local map = vim.keymap.set
local silent = { noremap = true, silent = true }

local function in_insert_mode()
  return vim.fn.mode():match("^[iR]") ~= nil
end

local function stop_insert()
  local was_insert = in_insert_mode()

  if was_insert then
    vim.cmd("stopinsert")
  end

  return was_insert
end

local function restore_insert(was_insert)
  if was_insert and vim.bo.buftype == "" then
    vim.cmd("startinsert")
  end
end

local function save_file()
  local was_insert = stop_insert()
  local name = vim.api.nvim_buf_get_name(0)

  if name == "" then
    local path = vim.fn.input("Save as: ", "", "file")

    if path == "" then
      restore_insert(was_insert)
      return
    end

    vim.cmd("write " .. vim.fn.fnameescape(vim.fn.expand(path)))
  else
    vim.cmd("silent write")
  end

  print("Saved")
  restore_insert(was_insert)
end

local function quit_editor()
  stop_insert()
  vim.cmd("confirm quit")
end

local function select_all()
  stop_insert()
  vim.cmd("normal! ggVG")
end

local function copy_text()
  local mode = vim.fn.mode()

  if mode:match("[vV\22]") then
    vim.cmd([[normal! "+y]])
  else
    vim.cmd([[normal! "+yy]])
  end

  print("Copied")
end

local function cut_text()
  local was_insert = stop_insert()
  local mode = vim.fn.mode()

  if mode:match("[vV\22]") then
    vim.cmd([[normal! "+d]])
  else
    vim.cmd([[normal! "+dd]])
  end

  print("Cut")
  restore_insert(was_insert)
end

local function find_in_file()
  local was_insert = stop_insert()
  local ok, builtin = pcall(require, "telescope.builtin")

  if ok then
    builtin.current_buffer_fuzzy_find()
    return
  end

  local pattern = vim.fn.input("Find: ")

  if pattern ~= "" then
    vim.fn.setreg("/", pattern)
    vim.opt.hlsearch = true
    vim.fn.search(pattern, "W")
  end

  restore_insert(was_insert)
end

local function replace_in_file()
  local was_insert = stop_insert()
  local find = vim.fn.input("Find: ")

  if find == "" then
    restore_insert(was_insert)
    return
  end

  local replacement = vim.fn.input("Replace with: ")
  local escaped_find = "\\V" .. vim.fn.escape(find, "\\/")
  local escaped_replacement = vim.fn.escape(replacement, "\\&/")

  vim.cmd("%s/" .. escaped_find .. "/" .. escaped_replacement .. "/gc")
  restore_insert(was_insert)
end

local function open_file()
  stop_insert()
  local ok, builtin = pcall(require, "telescope.builtin")

  if ok then
    builtin.find_files({ hidden = true })
    return
  end

  local path = vim.fn.input("Open file: ", "", "file")

  if path ~= "" then
    vim.cmd("confirm edit " .. vim.fn.fnameescape(vim.fn.expand(path)))
  end
end

local function search_project()
  stop_insert()
  local ok, builtin = pcall(require, "telescope.builtin")

  if ok then
    builtin.live_grep()
  else
    vim.cmd("grep ")
  end
end

local function toggle_explorer()
  stop_insert()
  local ok, api = pcall(require, "nvim-tree.api")

  if ok then
    api.tree.toggle({ focus = true })
  else
    vim.cmd("Explore")
  end
end

local function show_diagnostics()
  stop_insert()
  local ok, builtin = pcall(require, "telescope.builtin")

  if ok then
    builtin.diagnostics({ bufnr = 0 })
  else
    vim.diagnostic.setqflist()
    vim.cmd("copen")
  end
end

local function format_file()
  local was_insert = stop_insert()
  local ok, conform = pcall(require, "conform")

  if ok then
    conform.format({ async = false, timeout_ms = 1200, lsp_format = "fallback" })
  else
    vim.lsp.buf.format({ async = false })
  end

  restore_insert(was_insert)
end

local function help_buffer()
  stop_insert()
  local lines = {
    "Normal editor keys",
    "",
    "Ctrl-S        save",
    "Ctrl-Q        quit, asking about unsaved changes",
    "Ctrl-O/Ctrl-P open file picker",
    "Ctrl-E        file explorer",
    "Ctrl-F        find in this file",
    "Ctrl-Shift-F  search project, if your terminal sends it",
    "Ctrl-H        find and replace",
    "Ctrl-A        select all",
    "Ctrl-C        copy selection, or current line if nothing selected",
    "Ctrl-X        cut selection, or current line if nothing selected",
    "Ctrl-V        paste",
    "Ctrl-Z        undo",
    "Ctrl-Y        redo",
    "Ctrl-D        show lint/LSP diagnostics",
    "F2            rename symbol",
    "F12           go to definition",
    "F8/Shift-F8   next/previous diagnostic",
    "Ctrl-/        this help",
    "",
    "You can mostly type like a normal editor. Press Esc only if you want Vim commands.",
    "Press q to close this help.",
  }

  vim.cmd("botright 22new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "sway-rice-help"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = buf, silent = true })
end

map({ "n", "i", "v" }, "<C-s>", save_file, silent)
map({ "n", "i", "v" }, "<C-q>", quit_editor, silent)
map({ "n", "i", "v" }, "<C-a>", select_all, silent)
map("n", "<C-c>", copy_text, silent)
map("v", "<C-c>", '"+y', silent)
map({ "n", "i" }, "<C-x>", cut_text, silent)
map("v", "<C-x>", '"+d', silent)
map("n", "<C-v>", '"+p', silent)
map("i", "<C-v>", "<C-r>+", silent)
map("v", "<C-v>", '"+p', silent)
map("n", "<C-z>", "u", silent)
map("i", "<C-z>", "<C-o>u", silent)
map("v", "<C-z>", "<Esc>u", silent)
map("n", "<C-y>", "<C-r>", silent)
map("i", "<C-y>", "<C-o><C-r>", silent)
map("n", "<C-f>", find_in_file, silent)
map("i", "<C-f>", find_in_file, silent)
map("v", "<C-f>", find_in_file, silent)
map({ "n", "i", "v" }, "<C-h>", replace_in_file, silent)
map({ "n", "i", "v" }, "<C-o>", open_file, silent)
map({ "n", "i", "v" }, "<C-p>", open_file, silent)
map({ "n", "i", "v" }, "<C-e>", toggle_explorer, silent)
map({ "n", "i", "v" }, "<C-d>", show_diagnostics, silent)
map({ "n", "i", "v" }, "<F3>", format_file, silent)
map({ "n", "i", "v" }, "<C-_>", help_buffer, silent)
map({ "n", "i", "v" }, "<C-/>", help_buffer, silent)
map({ "n", "i", "v" }, "<C-S-f>", search_project, silent)

map("n", "<Esc>", "<cmd>nohlsearch<CR>", silent)
map("n", "<leader>w", save_file, silent)
map("n", "<leader>q", quit_editor, silent)
map("n", "<leader>Q", "<cmd>quitall<CR>", silent)
map("n", "<leader>e", toggle_explorer, silent)
map("n", "<leader>f", open_file, silent)
map("n", "<leader>/", search_project, silent)
map("n", "<leader>v", "<cmd>vsplit<CR>", silent)
map("n", "<leader>s", "<cmd>split<CR>", silent)
map("n", "<leader>n", "<cmd>set number! relativenumber!<CR>", silent)
map({ "n", "v" }, "<leader>y", '"+y', silent)
map("n", "<leader>p", '"+p', silent)
map("n", "<leader>h", "<C-w>h", silent)
map("n", "<leader>j", "<C-w>j", silent)
map("n", "<leader>k", "<C-w>k", silent)
map("n", "<leader>l", "<C-w>l", silent)

local group = vim.api.nvim_create_augroup("SwayRice", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    vim.schedule(function()
      if vim.bo.buftype == "" then
        vim.cmd("startinsert")
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 120 })
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  command = "tabdo wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.colorcolumn = ""
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and vim.lsp.completion and not package.loaded["blink.cmp"] then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    local buffer_map = function(lhs, rhs)
      vim.keymap.set({ "n", "i" }, lhs, rhs, { buffer = args.buf, silent = true, noremap = true })
    end

    buffer_map("<F2>", function()
      stop_insert()
      vim.lsp.buf.rename()
    end)

    buffer_map("<F12>", function()
      stop_insert()
      vim.lsp.buf.definition()
    end)

    buffer_map("<C-.>", function()
      stop_insert()
      vim.lsp.buf.code_action()
    end)
  end,
})

if vim.diagnostic then
  vim.diagnostic.config({
    virtual_text = { prefix = "", spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "single", source = "if_many" },
  })

  local signs = {
    Error = "",
    Warn = "",
    Info = "",
    Hint = "󰌵",
  }

  for severity, text in pairs(signs) do
    vim.fn.sign_define("DiagnosticSign" .. severity, {
      text = text,
      texthl = "DiagnosticSign" .. severity,
      numhl = "",
    })
  end

  map({ "n", "i" }, "<F8>", function()
    stop_insert()
    vim.diagnostic.jump({ count = 1, float = true })
  end, silent)

  map({ "n", "i" }, "<S-F8>", function()
    stop_insert()
    vim.diagnostic.jump({ count = -1, float = true })
  end, silent)
end

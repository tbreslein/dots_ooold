---@diagnostic disable: missing-fields
vim.g.mapleader = " "
vim.g.maplocalleader = ","
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy_path) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazy_path,
    })
end
vim.opt.rtp:prepend(lazy_path)
require("lazy").setup({
    -- common dependencies
    { "nvim-lua/plenary.nvim", lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- [[ UI ]]
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            vim.g.gruvbox_material_transparent_background = 1
            vim.g.gruvbox_material_dim_inactive_windows = 1
            vim.g.gruvbox_material_ui_contrast = "high"
            vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
            vim.cmd("colorscheme gruvbox-material")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "auto",
                component_separators = "",
                section_separators = "",
                globalstatus = true,
            },
            sections = {
                lualine_a = { { "mode", icon = "󰣇 ", fmt = function(str) return str:sub(1, 1) end } },
                lualine_b = {
                    { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
                },
                lualine_c = { "%=", { "filename", path = 1 } },
                lualine_x = {},
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
    { "yorickpeterse/nvim-pqf", event = "VeryLazy", opts = {} },
    { "airblade/vim-gitgutter", event = "BufEnter" },

    -- [[ Navigation ]]
    {
        "alexghergh/nvim-tmux-navigation",
        event = "VeryLazy",
        keys = {
            { "<c-h>", ":lua require('nvim-tmux-navigation').NvimTmuxNavigateLeft()<cr>" },
            { "<c-j>", ":lua require('nvim-tmux-navigation').NvimTmuxNavigateDown()<cr>" },
            { "<c-k>", ":lua require('nvim-tmux-navigation').NvimTmuxNavigateUp()<cr>" },
            { "<c-l>", ":lua require('nvim-tmux-navigation').NvimTmuxNavigateRight()<cr>" },
        },
    },
    {
        "MeanderingProgrammer/harpoon-core.nvim",
        event = "VeryLazy",
        opts = { menu = { width = 80 }, mark_branch = true },
        keys = {
            { "<m-u>", ":lua require('harpoon-core.ui').nav_file(1)<cr>" },
            { "<m-i>", ":lua require('harpoon-core.ui').nav_file(2)<cr>" },
            { "<m-o>", ":lua require('harpoon-core.ui').nav_file(3)<cr>" },
            { "<m-p>", ":lua require('harpoon-core.ui').nav_file(4)<cr>" },
            { "<leader>a", ":lua require('harpoon-core.mark').add_file()<cr>" },
            { "<leader>e", ":lua require('harpoon-core.ui').toggle_quick_menu()<cr>" },
        },
    },
    {
        "linrongbin16/fzfx.nvim",
        dependencies = "junegunn/fzf",
        opts = {},
        keys = {
            {
                "<leader>pf",
                function()
                    vim.fn.system("git rev-parse --is-inside-work-tree")
                    if vim.v.shell_error == 0 then
                        vim.cmd("FzfxGFiles")
                    else
                        vim.cmd("FzfxFiles")
                    end
                end,
            },
            { "<leader>pg", ":FzfxFiles<cr>" },
            { "<leader>ps", ":FzfxLiveGrep<cr>" },
        },
    },

    -- [[ Editing ]]
    { "mbbill/undotree", event = "BufEnter" },
    { "numtostr/Comment.nvim", event = "BufEnter", opts = {} },
    { "echasnovski/mini.surround", event = "BufEnter", opts = {} },
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/nvim-treesitter-textobjects",
            "windwp/nvim-ts-autotag",
        },
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "markdown", "markdown_inline", "lua" },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                autotag = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["ai"] = "@conditional.outer",
                            ["ii"] = "@conditional.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["as"] = "@block.outer",
                            ["is"] = "@block.inner",
                        },
                    },
                },
            })
            require("treesitter-context").setup({ multiline_threshold = 2 })
        end,
    },
    {
        "nvim-neorg/neorg",
        -- ft = "norg",
        build = ":Neorg sync-parsers",
        opts = {
            load = {
                ["core.defaults"] = {},
                ["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
                ["core.integrations.nvim-cmp"] = {},
                ["core.concealer"] = {},
                ["core.summary"] = {},
                ["core.dirman"] = {
                    config = {
                        workspaces = { root = "~/MEGA/notes" },
                        default_workspace = "root",
                    },
                },
            },
        },
    },
    {
        "akinsho/git-conflict.nvim",
        event = "BufEnter",
        opts = { default_mappings = false },
        keys = {
            { "<leader>cn", ":GitConflictNextConflict<cr>" },
            { "<leader>cp", ":GitConflictPrevConflict<cr>" },
            { "<leader>co", ":GitConflictChooseOurs<cr>" },
            { "<leader>ct", ":GitConflictChooseTheirs<cr>" },
            { "<leader>cb", ":GitConflictChooseBoth<cr>" },
            { "<leader>c0", ":GitConflictChooseNone<cr>" },
            { "<leader>cl", ":GitConflictListQf<cr>" },
        },
    },

    -- [[ LSP ]]
    { "j-hui/fidget.nvim", branch = "legacy", event = "VeryLazy", opts = {} },
    {
        "VonHeikemen/lsp-zero.nvim",
        event = "VeryLazy",
        branch = "v3.x",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "nvimtools/none-ls.nvim",
            "onsails/lspkind.nvim",
        },
        config = function()
            local lsp_zero = require("lsp-zero")
            lsp_zero.on_attach(function(_, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
                vim.keymap.set("n", "gn", ":lua vim.diagnostic.goto_next()<cr>")
                vim.keymap.set("n", "gp", ":lua vim.diagnostic.goto_prev()<cr>")
            end)
            lsp_zero.setup_servers({
                "astro",
                "clangd",
                "cmake",
                "gopls",
                "html",
                "nil_ls",
                "svelte",
                "tsserver",
                "uiua",
                "rust_analyzer",
                "zls",
            })

            local lspconfig = require("lspconfig")
            lspconfig.pyright.setup({
                capabilities = lsp_zero.get_capabilities(),
                on_new_config = function(config, root_dir)
                    local env = vim.trim(
                        vim.fn.system('cd "' .. (root_dir or ".") .. '"; poetry env info --executable 2>/dev/null')
                    )
                    if string.len(env) > 0 then config.settings.python.pythonPath = env end
                end,
            })
            lspconfig.lua_ls.setup(lsp_zero.nvim_lua_ls())

            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<c-f>"] = lsp_zero.cmp_action().luasnip_jump_forward(),
                    ["<c-b>"] = lsp_zero.cmp_action().luasnip_jump_backward(),
                    ["<c-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<c-d>"] = cmp.mapping.scroll_docs(4),
                }),
                enabled = function() return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" end,
                formatting = {
                    format = function(entry, vim_item)
                        local kind = require("lspkind").cmp_format({
                            mode = "symbol_text",
                            maxwidth = 40,
                        })(entry, vim_item)
                        local strings = vim.split(kind.kind, "%s", { trimempty = true })
                        kind.kind = " " .. (strings[1] or "") .. " "
                        kind.menu = "    (" .. (strings[2] or "") .. ")"
                        return kind
                    end,
                },
                sources = { { name = "nvim_lsp" }, { name = "buffer" } },
            })
            local cmp_mappings = cmp.mapping.preset.cmdline({
                ["<c-p>"] = {
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            cmp.complete()
                        end
                    end,
                },
                ["<c-n>"] = {
                    c = function()
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            cmp.complete()
                        end
                    end,
                },
                ["<c-e>"] = { c = cmp.mapping.abort() },
                ["<c-y>"] = { c = cmp.mapping.confirm({ select = true }) },
            })
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp_mappings,
                sources = { { name = "buffer" } },
            })
            cmp.setup.cmdline({ ":" }, {
                mapping = cmp_mappings,
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })

            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.diagnostics.cppcheck,
                    null_ls.builtins.diagnostics.cmake_lint,
                    null_ls.builtins.formatting.clang_format,
                    null_ls.builtins.formatting.cmake_format,
                    null_ls.builtins.diagnostics.golangci_lint,
                    null_ls.builtins.formatting.gofumpt,
                    null_ls.builtins.formatting.rustfmt,
                    null_ls.builtins.formatting.zigfmt,

                    -- null_ls.builtins.diagnostics.flake8.with({ prefer_local = ".venv/bin" }),
                    null_ls.builtins.formatting.black.with({ prefer_local = ".venv/bin" }),
                    -- null_ls.builtins.diagnostics.ruff,

                    null_ls.builtins.code_actions.statix,
                    null_ls.builtins.diagnostics.statix,
                    null_ls.builtins.formatting.nixfmt,

                    null_ls.builtins.code_actions.shellcheck,
                    null_ls.builtins.diagnostics.shellcheck,
                    null_ls.builtins.diagnostics.hadolint,
                    null_ls.builtins.diagnostics.yamllint,
                    null_ls.builtins.diagnostics.zsh,
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.code_actions.eslint.with({ prefer_local = "node_modules/.bin" }),
                    null_ls.builtins.diagnostics.eslint.with({ prefer_local = "node_modules/.bin" }),
                    null_ls.builtins.diagnostics.tsc.with({ prefer_local = "node_modules/.bin" }),
                    null_ls.builtins.formatting.prettierd.with({
                        prefer_local = "node_modules/.bin",
                        disabled_filetypes = { "yaml" },
                    }),
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function() vim.lsp.buf.format() end,
                        })
                    end
                end,
            })
        end,
    },
})

-- [[ Vim Settings ]]
vim.opt.guicursor = ""
vim.opt.showmode = false
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.foldenable = false
vim.opt.conceallevel = 2
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.mouse = "a"

vim.keymap.set("n", "<leader>w", ":w<cr>", { silent = false })
vim.keymap.set("n", "<esc>", ":noh<cr>")
vim.keymap.set({ "n", "v" }, "Q", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v", "x" }, "x", '"_x')
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "P", '"_dP')
vim.keymap.set("n", "Y", "yg$")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set({ "n", "v" }, "<c-d>", "<c-d>zz")
vim.keymap.set({ "n", "v" }, "<c-u>", "<c-u>zz")
vim.keymap.set({ "n", "v" }, "n", "nzzzv")
vim.keymap.set({ "n", "v" }, "N", "Nzzzv")
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set("n", "<leader>fk", ":cprev<cr>zz")
vim.keymap.set("n", "<leader>fj", ":cnext<cr>zz")
vim.keymap.set("n", "<F11>", ":cprev<cr>zz")
vim.keymap.set("n", "<F12>", ":cnext<cr>zz")
vim.keymap.set("n", "<leader>ft", function()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            qf_exists = true
            break
        end
    end
    if qf_exists == true then return vim.cmd("cclose") end
    if not vim.tbl_isempty(vim.fn.getqflist()) then return vim.cmd("copen") end
end)

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank() end,
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
})
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "git", "gitcommit", "help", "lspinfo", "man", "query", "vim" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

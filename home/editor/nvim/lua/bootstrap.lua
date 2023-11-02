local function clone_paq()
    local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
    local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
    if not is_installed then
        vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path })
        return true
    end
end

local function bootstrap_paq(packages)
    local first_install = clone_paq()
    vim.cmd.packadd("paq-nvim")
    local paq = require("paq")
    if first_install then
        vim.notify("Installing plugins... If prompted, hit Enter to continue.")
    end
    paq(packages)
    paq.clean()
    paq.install()
    paq.update()
end

local packages = {
    "savq/paq-nvim",
    -- common deps
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",

    -- UI
    "sainnhe/gruvbox-material",

    -- Navigation
    "alexghergh/nvim-tmux-navigation",
    "MeanderingProgrammer/harpoon-core.nvim",
    "nvim-telescope/telescope.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = 'make' },

    -- Editing
    "mbbill/undotree",
    "numtostr/Comment.nvim",
    "echasnovski/mini.surround",
    { "nvim-treesitter/nvim-treesitter", build = ':TSUpdate' },
    "nvim-treesitter/nvim-treesitter-context",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",
    "akinsho/git-conflict.nvim",

    -- LSP
    { "j-hui/fidget.nvim", branch = "legacy" },
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "onsails/lspkind.nvim",

    -- Formatting + Linting
    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint",
}

local function headless_paq()
    vim.cmd("autocmd User PaqDoneInstall quit")
    bootstrap_paq(packages)
end

return { headless_paq = headless_paq, packages = packages }

--[[
    -- LSP
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
--]]

--require("paq")(require("bootstrap").packages)
-- {{ Vim Settings }}
vim.g.mapleader = " "
vim.opt.guicursor = ""
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
vim.opt.conceallevel = 0
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
vim.opt.undofile = true
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.background = "dark"
vim.opt.fileencoding = "utf-8"
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
vim.g.gruvbox_material_dim_inactive_windows = 1
vim.g.gruvbox_material_transparent_background = 1
vim.g.gruvbox_material_ui_contrast = "high"
vim.cmd("colorscheme gruvbox-material")

-- {{ Keymaps }}
local function kmap(modes, bindings, action, opts)
    local _opts = { silent = true, expr = false, noremap = true }
    if opts ~= nil then _opts = vim.tbl_deep_extend("force", _opts, opts) end
    if type(bindings) == "table" then
        for _, bind in ipairs(bindings) do
            vim.keymap.set(modes, bind, action, _opts)
        end
    else
        vim.keymap.set(modes, bindings, action, _opts)
    end
end

kmap("i", { "jk", "kj" }, "<esc>")
kmap("n", "<leader>w", ":w<cr>", { silent = false })
kmap("v", "<leader>r", '"hy:%s/<c-r>h//g<left><left>', { silent = false })
kmap("v", "<leader>s", ":sort<cr>")
kmap("n", "<esc>", ":noh<cr>")
kmap({ "n", "v" }, "Q", "<nop>")
kmap({ "n", "v", "x" }, "<leader>y", '"+y')
kmap({ "n", "v", "x" }, "<leader>p", '"+p')
kmap({ "n", "v", "x" }, "x", '"_x')
kmap("v", ">", ">gv")
kmap("v", "<", "<gv")
kmap("v", "K", ":m '<-2<cr>gv=gv")
kmap("v", "J", ":m '>+1<cr>gv=gv")
kmap("v", "P", '"_dP')
kmap("n", "Y", "yg$")
kmap("n", "J", "mzJ`z")
kmap({ "n", "v" }, "<c-d>", "<c-d>zz")
kmap({ "n", "v" }, "<c-u>", "<c-u>zz")
kmap({ "n", "v" }, "n", "nzzzv")
kmap({ "n", "v" }, "N", "Nzzzv")
kmap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
kmap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
kmap("n", { "<leader>fk", "<F11>" }, ":cprev<cr>zz")
kmap("n", { "<leader>fj", "<F12>" }, ":cnext<cr>zz")
kmap("n", "<leader>ft", function()
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

-- {{ Navigation }}
kmap("n", "<c-h>", require("nvim-tmux-navigation").NvimTmuxNavigateLeft)
kmap("n", "<c-j>", require("nvim-tmux-navigation").NvimTmuxNavigateDown)
kmap("n", "<c-k>", require("nvim-tmux-navigation").NvimTmuxNavigateUp)
kmap("n", "<c-l>", require("nvim-tmux-navigation").NvimTmuxNavigateRight)

require("harpoon-core").setup()
kmap("n", "<m-u>", ":lua require('harpoon-core.ui').nav_file(1)<cr>")
kmap("n", "<m-i>", ":lua require('harpoon-core.ui').nav_file(2)<cr>")
kmap("n", "<m-o>", ":lua require('harpoon-core.ui').nav_file(3)<cr>")
kmap("n", "<m-p>", ":lua require('harpoon-core.ui').nav_file(4)<cr>")
kmap("n", "<leader>a", require("harpoon-core.mark").add_file)
kmap("n", "<leader>e", require("harpoon-core.ui").toggle_quick_menu)

require("telescope").setup({ defaults = {
    layout_strategy = "vertical",
    layout_config = { height = 0.95 },
} })
require("telescope").load_extension("fzf")
kmap("n", "<leader>pf", function()
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
        require("telescope.builtin").git_files()
    else
        require("telescope.builtin").find_files()
    end
end)
kmap("n", "<leader>pg", require("telescope.builtin").git_files)
kmap("n", "<leader>ps", require("telescope.builtin").live_grep)

-- {{ Editing }}
kmap("n", "<leader>U", vim.cmd.UndotreeToggle)
require("Comment").setup()
require("mini.surround").setup()
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
require("git-conflict").setup({ default_mappings = false })
kmap("n", "<leader>cn", ":GitConflictNextConflict<cr>")
kmap("n", "<leader>cp", ":GitConflictPrevConflict<cr>")
kmap("n", "<leader>co", ":GitConflictChooseOurs<cr>")
kmap("n", "<leader>ct", ":GitConflictChooseTheirs<cr>")
kmap("n", "<leader>cb", ":GitConflictChooseBoth<cr>")
kmap("n", "<leader>cv", ":GitConflictChooseNone<cr>")
kmap("n", "<leader>cl", ":GitConflictChooseListQf<cr>")

-- {{ LSP }}
require("fidget").setup()
local lspconfig = require("lspconfig")
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = {
    "astro",
    "clangd",
    "cmake",
    "gopls",
    "html",
    "marksman",
    "nil_ls",
    "svelte",
    "tsserver",
    "uiua",
    "rust_analyzer",
    "zls",
}
for _, server in ipairs(servers) do
    lspconfig[server].setup({ capabilities = lsp_capabilities })
end
lspconfig.pyright.setup({
    capabilities = lsp_capabilities,
    on_new_config = function(config, root_dir)
        local env =
            vim.trim(vim.fn.system('cd "' .. (root_dir or ".") .. '"; poetry env info --executable 2>/dev/null'))
        if string.len(env) > 0 then config.settings.python.pythonPath = env end
    end,
})

local cmp = require("cmp")
local select_opts = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
    snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    window = { documentation = cmp.config.window.bordered() },
    mapping = cmp.mapping.preset.insert({
        ["<c-u>"] = cmp.mapping.scroll_docs(-4),
        ["<c-d>"] = cmp.mapping.scroll_docs(4),
        ["<c-n>"] = cmp.mapping.select_next_item(select_opts),
        ["<c-p>"] = cmp.mapping.select_prev_item(select_opts),
        ["<c-e>"] = cmp.mapping.abort(),
        ["<c-y>"] = cmp.mapping.confirm({ select = true }),
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
    sources = {
        { name = "path" },
        { name = "nvim_lsp", keyword_length = 1 },
        { name = "buffer", keyword_length = 3 },
        { name = "luasnip" },
    },
})
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
})
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.hover, { border = "rounded" })

-- {{ Formatting + Linting }}
require("conform").setup({
    formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        cmake = { "cmake_format" },
        go = { "gofumpt" },
        rust = { "rustfmt" },
        zig = { "zigfmt" },
        python = { "black" },
        lua = { "stylua" },
        markdown = { "prettierd" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        nix = { "nixfmt" },
    },
    format_after_save = { lsp_fallback = false },
    notify_on_error = false,
})
require("lint").linters_by_ft = {
    c = { "cppcheck" },
    cpp = { "cppcheck" },
    cmake = { "cmakelint" },
    go = { "golangcilint" },
    python = { "ruff" },
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    svelte = { "eslint_d" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    nix = { "nix", "statix" },
    dockerfile = { "hadolint" },
    yaml = { "yamllint" },
}

-- {{ Autocommands }}
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
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function()
        local bufmap = function(mode, lhs, rhs) kmap(mode, lhs, rhs, { buffer = true }) end
        bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
        bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
        bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
        bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
        bufmap("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
        bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")
        bufmap("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
        bufmap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>")
        bufmap("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>")
        bufmap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
        bufmap("n", "gp", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
        bufmap("n", "gn", "<cmd>lua vim.diagnostic.goto_next()<cr>")
    end,
})
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function() require("lint").try_lint() end,
})

-- {{ Statusline }}
function statusline()
    local function lsp_status()
        local nums = {
            #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
            #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
            #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
            #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
        }
        local out = ""
        if nums[1] > 0 then out = out .. " %#Red# " .. nums[1] end
        if nums[2] > 0 then out = out .. " %#Yellow# " .. nums[2] end
        if nums[3] > 0 then out = out .. " %#Green# " .. nums[3] end
        if nums[4] > 0 then out = out .. " %#Blue# " .. nums[4] end
        if out:len() > 0 then out = " |" .. out end
        return out
    end
    return table.concat({ "%f", "%m", "%=", "%p%% %l:%c", lsp_status() })
end
vim.cmd([[ set statusline=%!luaeval('statusline()') ]])

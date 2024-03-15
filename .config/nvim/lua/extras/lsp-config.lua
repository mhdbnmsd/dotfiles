
local lsp_zero = require('lsp-zero')
lsp_zero.extend_lspconfig()

lsp_zero.on_attach(function(_, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end
    --  To jump back, press <C-t>.
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {'rust_analyzer', 'tsserver', 'lua_ls',  'eslint', 'bashls', 'jsonls'},
    handlers = {
        lsp_zero.default_setup,
        jdtls = lsp_zero.noop,
    },
})

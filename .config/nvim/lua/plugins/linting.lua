return {
    {
        "mfussenegger/nvim-lint",
        event = "VeryLazy",
        opts = {
            -- Event to trigger linters
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },
            linters_by_ft = {
                -- Use the "*" filetype to run linters on all filetypes.
                ['*'] = { 'global linter' },
                -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
                ['_'] = { 'fallback linter' },
            },
            -- LazyVim extension to easily override linter options
            ---@type table<string,table>
            linters = {
            },
        },
        config = function(_, _)
            local lint = require("lint")
            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })
            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },
}

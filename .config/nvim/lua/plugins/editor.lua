return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        keys = {
            {
                "<leader>fe",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
                end,
                desc = "Explorer NeoTree (root dir)",
            },
            {
                "<leader>ge",
                function()
                    require("neo-tree.command").execute({ source = "git_status", toggle = true })
                end,
                desc = "Git explorer",
            },
            {
                "<leader>be",
                function()
                    require("neo-tree.command").execute({ source = "buffers", toggle = true })
                end,
                desc = "Buffer explorer",
            },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            if vim.fn.argc(-1) == 1 then
                local stat = vim.loop.fs_stat(vim.fn.argv(0))
                if stat and stat.type == "directory" then
                    require("neo-tree")
                end
            end
        end,
        opts = {
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
            window = {
                mappings = {
                    ["<space>"] = "none",
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
            },
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)

            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED,   handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
            })
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end
    },
    -- End of NeoTree
    {
        "nvim-pack/nvim-spectre",
        build = false,
        cmd = "Spectre",
        opts = { open_cmd = "noswapfile vnew" },
        -- stylua: ignore
        keys = {
            { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
    },
    -- End of specter
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            plugins = { spelling = true },
            defaults = {
                mode = { "n", "v" },
                ["g"] = { name = "+goto" },
                ["gs"] = { name = "+surround" },
                ["]"] = { name = "+next" },
                ["["] = { name = "+prev" },
                ["<leader><tab>"] = { name = "+tabs" },
                ["<leader>b"] = { name = "+buffer" },
                ["<leader>c"] = { name = "+code" },
                ["<leader>f"] = { name = "+file/find" },
                ["<leader>g"] = { name = "+git" },
                ["<leader>gh"] = { name = "+hunks" },
                ["<leader>q"] = { name = "+quit/session" },
                ["<leader>s"] = { name = "+search" },
                ["<leader>u"] = { name = "+ui" },
                ["<leader>w"] = { name = "+windows" },
                ["<leader>x"] = { name = "+diagnostics/quickfix" },
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.register(opts.defaults)
        end,
    },
    -- End of which-key
    {
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostic_signs = true },
        keys = {
            { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
            { "<leader>xL", "<cmd>TroubleToggle loclist<cr>",               desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List (Trouble)" },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").previous({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cprev)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Previous trouble/quickfix item",
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cnext)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Next trouble/quickfix item",
            },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        version = false, -- telescope did only one release, so use HEAD for now
        keys = {
            {
                "<leader>,",
                "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
                desc = "Switch Buffer",
            },
            { "<leader>/",       "<cmd>Telescope live_grep<cr>", desc = "Grep (root dir)" },
            { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
            { "<leader>:",       "<cmd>Telescope command_history<cr>", desc = "Command History" },
            -- git
            { "<leader>gc",      "<cmd>Telescope git_commits<CR>", desc = "commits" },
            { "<leader>gs",      "<cmd>Telescope git_status<CR>", desc = "status" },
            -- search
            { '<leader>s"',      "<cmd>Telescope registers<cr>", desc = "Registers" },
            { "<leader>sa",      "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
            { "<leader>sb",      "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
            { "<leader>sc",      "<cmd>Telescope command_history<cr>", desc = "Command History" },
            { "<leader>sC",      "<cmd>Telescope commands<cr>", desc = "Commands" },
            { "<leader>sd",      "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
            { "<leader>sD",      "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
            { "<leader>sh",      "<cmd>Telescope help_tags<cr>",  desc = "Help Pages" },
            { "<leader>sH",      "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
            { "<leader>sk",      "<cmd>Telescope keymaps<cr>",  desc = "Key Maps" },
            { "<leader>sM",      "<cmd>Telescope man_pages<cr>",  desc = "Man Pages" },
            { "<leader>sm",      "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
            { "<leader>so",      "<cmd>Telescope vim_options<cr>", desc = "Options" },
            { "<leader>sR",      "<cmd>Telescope resume<cr>", desc = "Resume" },
        },
        opts = function()
            local actions = require("telescope.actions")

            local open_with_trouble = function(...)
                return require("trouble.providers.telescope").open_with_trouble(...)
            end
            local open_selected_with_trouble = function(...)
                return require("trouble.providers.telescope").open_selected_with_trouble(...)
            end

            return {
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    -- open files in the first window that is an actual file.
                    -- use the current window if no other window is available.
                    get_selection_window = function()
                        local wins = vim.api.nvim_list_wins()
                        table.insert(wins, 1, vim.api.nvim_get_current_win())
                        for _, win in ipairs(wins) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if vim.bo[buf].buftype == "" then
                                return win
                            end
                        end
                        return 0
                    end,
                    mappings = {
                        i = {
                            ["<c-t>"] = open_with_trouble,
                            ["<a-t>"] = open_selected_with_trouble,
                            ["<C-Down>"] = actions.cycle_history_next,
                            ["<C-Up>"] = actions.cycle_history_prev,
                            ["<C-f>"] = actions.preview_scrolling_down,
                            ["<C-b>"] = actions.preview_scrolling_up,
                        },
                        n = {
                            ["q"] = actions.close,
                        },
                    },
                },
            }
        end,
    },
    -- End of Trouble
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    { "nvim-lua/plenary.nvim", lazy = true }
}

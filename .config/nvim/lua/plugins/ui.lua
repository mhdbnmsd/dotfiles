return {
    {
        "nvim-lualine/lualine.nvim", -- Neovim status line
        dependencies = {
            "SmiteshP/nvim-navic",
            "onsails/lspkind-nvim",
        },
        lazy = false,
        priority = 999,
        config = function()
            local lualine = require("lualine")
            local nvim_navic = require("nvim-navic")
            nvim_navic.setup({
                seperator = "",
                highlight = true,
            })
            local create_symbol_bar = function()
                if not nvim_navic.is_available() then
                    return ""
                end
                local details = {}
                for _, item in ipairs(nvim_navic.get_data()) do
                    -- For some reason sumneko adds a random ` ->` to the end of the name *sometimes*
                    -- This accounts for that I guess...
                    table.insert(details, item.icon .. item.name:gsub("%s*->%s*", ""))
                    -- Looks like we have some more weirdness coming from sumneko...
                end
                return table.concat(details, " > ")
            end
            local format_name = function(output)
                return output
            end
            local branch_max_width = 40
            local branch_min_width = 10
            lualine.setup({
                options = {
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        "mode",
                        {
                            "branch",
                            fmt = function(output)
                                local win_width = vim.o.columns
                                local max = branch_max_width
                                if win_width * 0.25 < max then
                                    max = math.floor(win_width * 0.25)
                                end
                                if max < branch_min_width then
                                    max = branch_min_width
                                end
                                if max % 2 ~= 0 then
                                    max = max + 1
                                end
                                if output:len() >= max then
                                    return output:sub(1, (max / 2) - 1)
                                        .. "..."
                                        .. output:sub( -1 * ((max / 2) - 1), -1)
                                end
                                return output
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            "filename",
                            file_status = false,
                            path = 1,
                            fmt = format_name,
                        },
                        {
                            "diagnostics",
                            update_in_insert = true,
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        "import",
                    },
                    -- Combine x and y
                    lualine_y = {
                        {
                            function()
                                local lsps = vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
                                local icon = require("nvim-web-devicons").get_icon_by_filetype(
                                    vim.api.nvim_buf_get_option(0, "filetype")
                                )
                                if lsps and #lsps > 0 then
                                    local names = {}
                                    for _, lsp in ipairs(lsps) do
                                        table.insert(names, lsp.name)
                                    end
                                    return string.format("%s %s", table.concat(names, ", "), icon)
                                else
                                    return icon or ""
                                end
                            end,
                            on_click = function()
                                vim.api.nvim_command("LspInfo")
                            end,
                            color = function()
                                local _, color = require("nvim-web-devicons").get_icon_cterm_color_by_filetype(
                                    vim.api.nvim_buf_get_option(0, "filetype")
                                )
                                return { fg = color }
                            end,
                        },
                        "encoding",
                        "progress",
                    },
                    lualine_z = {
                        "location",
                        {
                            function()
                                local starts = vim.fn.line("v")
                                local ends = vim.fn.line(".")
                                local count = starts <= ends and ends - starts + 1 or starts - ends + 1
                                return count .. "V"
                            end,
                            cond = function()
                                return vim.fn.mode():find("[Vv]") ~= nil
                            end,
                        },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filetype",
                            icon_only = true,
                        },
                        {
                            "filename",
                            path = 1,
                            fmt = format_name,
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                winbar = {
                    lualine_a = {
                        { "filetype", icon_only = true,    icon = { align = "left" } },
                        { "filename", file_status = false, path = 0 },
                    },
                    lualine_b = {},
                    lualine_c = { create_symbol_bar },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_winbar = {
                    lualine_a = {
                        { "filetype", icon_only = true,    icon = { align = "left" } },
                        { "filename", file_status = false, path = 0 },
                    },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        opts = {
            indent = { highlight = { "CursorColumn", "Whitespace", }, char = "" },
            whitespace = {
                highlight = { "CursorColumn", "Whitespace", },
                remove_blankline_trail = false,
            },
            scope = { enabled = false },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                },
            },
        },
        main = "ibl",
    },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true }
}

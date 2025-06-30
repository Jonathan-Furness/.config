return {
  "vuki656/package-info.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  event = { "BufRead package.json", "BufRead package-lock.json" },
  config = function()
    local package_info = require("package-info")

    -- Setup package-info
    package_info.setup({
      colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
        invalid = "#ee4b2b",
      },
      icons = {
        enable = true,
        style = {
          up_to_date = "|  ",
          outdated = "|  ",
          invalid = "|  ",
        },
      },
      autostart = true,
      hide_up_to_date = false,
      hide_unstable_versions = false,
      package_manager = "pnpm", -- npm, yarn, pnpm
    })

    -- Keybindings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Function to register which-key group only in package.json files
    local function register_package_group()
      local ok, wk = pcall(require, "which-key")
      if ok then
        local filename = vim.fn.expand("%:t")
        if filename == "package.json" or filename == "package-lock.json" then
          wk.add({
            { "<leader>p", group = "Package Management", icon = "" },
          })
        end
      end
    end

    -- Register group on buffer enter
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = { "package.json", "package-lock.json" },
      callback = register_package_group,
    })

    -- Show dependency versions
    keymap("n", "<leader>ps", package_info.show, vim.tbl_extend("force", opts, { desc = "Show package versions" }))

    -- Hide dependency versions
    keymap("n", "<leader>ph", package_info.hide, vim.tbl_extend("force", opts, { desc = "Hide package versions" }))

    -- Toggle dependency versions
    keymap("n", "<leader>pt", package_info.toggle, vim.tbl_extend("force", opts, { desc = "Toggle package versions" }))

    -- Update dependency on the line
    keymap(
      "n",
      "<leader>pu",
      package_info.update,
      vim.tbl_extend("force", opts, { desc = "Update package under cursor" })
    )

    -- Delete dependency on the line
    keymap(
      "n",
      "<leader>pd",
      package_info.delete,
      vim.tbl_extend("force", opts, { desc = "Delete package under cursor" })
    )

    -- Install a new dependency with version
    keymap("n", "<leader>pi", package_info.install, vim.tbl_extend("force", opts, { desc = "Install new package" }))

    -- Install a different dependency version
    keymap(
      "n",
      "<leader>pp",
      package_info.change_version,
      vim.tbl_extend("force", opts, { desc = "Change package version" })
    )

    -- Show dependency popup
    keymap(
      "n",
      "<leader>pv",
      package_info.show_dependency_popup,
      vim.tbl_extend("force", opts, { desc = "Show package info popup" })
    )
  end,
}

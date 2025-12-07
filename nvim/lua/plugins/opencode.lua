return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `toggle()`.
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }

    -- Required for `vim.g.opencode_opts.auto_reload`
    vim.opt.autoread = true

    -- Register which-key group
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "<leader>a", "ai", icon = "" },
      })
    end

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>aa", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>as", function()
      require("opencode").select()
    end, { desc = "Select prompt" })

    vim.keymap.set({ "n", "x" }, "<leader>aS", function()
      require("opencode").command("session.list")
    end, { desc = "List sessions" })

    vim.keymap.set({ "n", "x" }, "<leader>a+", function()
      require("opencode").prompt("@this")
    end, { desc = "Add this" })

    vim.keymap.set("n", "<leader>an", function()
      require("opencode").command("session.new")
    end, { desc = "New session" })

    vim.keymap.set("n", "<leader>oi", function()
      require("opencode").command("session.interrupt")
    end, { desc = "Interrupt session" })

    vim.keymap.set("n", "<M-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Messages half page up" })

    vim.keymap.set("n", "<M-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Messages half page down" })
  end,
}

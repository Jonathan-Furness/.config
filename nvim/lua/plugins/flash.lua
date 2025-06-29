return {
  "folke/flash.nvim",
  keys = {
    {
      "sc",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
  },
  ---@type Flash.Config
  opts = {
    search = {
      mode = "search",
    },
  },
}

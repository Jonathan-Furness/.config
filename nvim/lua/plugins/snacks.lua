return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {
      -- your explorer configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      win = {
        number = true,
        wo = {
          smoothscroll = false,
        },
      },
    },
  },
}

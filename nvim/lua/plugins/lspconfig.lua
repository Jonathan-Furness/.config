return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable pyright in favor of ty
        pyright = {
          enabled = false,
        },
        ty = {},
      },
    },
  },
}

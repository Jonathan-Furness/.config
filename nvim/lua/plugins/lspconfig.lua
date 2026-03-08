return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable pyright in favor of ty
        pyright = {
          enabled = false,
        },
        ruff = {
          cmd = { "uv", "run", "ruff", "server" },
        },
        ty = {
          cmd = { "uv", "run", "ty", "server" },
        },
      },
    },
  },
}

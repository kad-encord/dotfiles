return {
  {
    "windwp/nvim-ts-autotag",
    event = function()
      return "VeryLazy"
    end,
    opts = {
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
    },
  },
}

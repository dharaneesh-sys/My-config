-- ~/.config/nvim/lua/plugins/neo-tree.lua
-- Show hidden files + bypass remap chain to fix double file explorer

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = LazyVim.root(),
          })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = vim.uv.cwd(),
          })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = LazyVim.root(),
          })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = vim.uv.cwd(),
          })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          never_show = { ".DS_Store", "thumbs.db" },
        },
      },
    },
  },
}

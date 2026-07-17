return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function() require('fff.download').download_or_build_binary() end,
    keys = {
      -- File finding (matches LazyVim defaults)
      { "<leader><space>", function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },
      { "<leader>ff",      function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },
      { "<leader>fF",      function() require("fff").find_files() end, desc = "Find Files (cwd)" },
      -- Grep (matches LazyVim defaults)
      { "<leader>/",       function() require("fff").live_grep() end,  desc = "Grep (Root Dir)" },
      { "<leader>sg",      function() require("fff").live_grep() end,  desc = "Grep (Root Dir)" },
      { "<leader>sG",      function() require("fff").live_grep() end,  desc = "Grep (cwd)" },
      -- Word under cursor (matches LazyVim <leader>sw)
      { "<leader>sw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "Word (Root Dir)", mode = { "n", "v" } },
      { "<leader>sW", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "Word (cwd)",      mode = { "n", "v" } },
    },
    opts = {},
  },
}

vim.pack.add({
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
})
vim.g.dbs = {}

if vim.env.LOCAL_LOGGING_DB_URL and vim.env.LOCAL_LOGGING_DB_URL ~= "" then
  table.insert(vim.g.dbs, {
    name = "localLogging",
    url = function()
      return vim.env.LOCAL_LOGGING_DB_URL
    end,
  })

  table.insert(vim.g.dbs, {
    name = "localTestlit",
    url = function()
      return vim.env.LOCAL_TESTLIT_DB_URL
    end,
  })

  table.insert(vim.g.dbs, {
    name = "alphaLogging",
    url = function()
      return vim.env.ALPHA_LOGGING_DB_URL
    end,
  })

  table.insert(vim.g.dbs, {
    name = "alphaTestlit",
    url = function()
      return vim.env.ALPHA_TESTLIT_DB_URL
    end,
  })
end

if vim.env.MUSIC_LEAGUE_DB_URL and vim.env.MUSIC_LEAGUE_DB_URL ~= "" then
    table.insert(vim.g.dbs, {
    name = "musicleague",
    url = function()
        return vim.env.MUSIC_LEAGUE_DB_URL
    end,
    })
end

vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<cr>", { desc = "DB connect" })

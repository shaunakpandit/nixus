vim.pack.add({
	{ src = "https://github.com/mcauley-penney/techbase.nvim" },
})

-- optional: configure before loading the colorscheme
require("techbase").setup({
	italic_comments = false,
	transparent = false,
	hl_overrides = {},
})

-- "sw1comm"
-- "techbase"
vim.cmd.colorscheme("sw1comm")

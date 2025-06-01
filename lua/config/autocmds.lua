-- On yank
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- On terminal open
vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- Auto-disable scrollbind & cursorbind in any new or entered window
vim.api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
	callback = function()
		vim.wo.scrollbind = false
		vim.wo.cursorbind = false
	end,
})

-- If the ‘diff’ option turns on, clear it immediately
vim.api.nvim_create_autocmd({ "OptionSet" }, {
	pattern = "diff",
	callback = function()
		vim.wo.scrollbind = false
		vim.wo.cursorbind = false
	end,
})

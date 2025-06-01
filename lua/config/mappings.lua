-- Lua execution and sourcing
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")
vim.keymap.set("n", "<space>z", "ggVG:lua<CR>")

-- Oil commands
vim.keymap.set("n", "-", "<cmd>Oil<CR>")
vim.keymap.set("n", "<leader>s", "<C-w>v<C-w>l<cmd>tcd ~/scratch<CR><cmd>Oil ~/scratch<CR>")
vim.keymap.set("n", "<leader>op", "<cmd>Oil ~/Projects/<CR>")
vim.keymap.set("n", "<leader>on", "<cmd>Oil ~/.config/nvim/<CR>")

vim.keymap.set("i", "<c-'>", "`")
-- Window selection
-- smart window mover: if you can move in direction `d` do so,
-- otherwise split in that direction.
local function clear_all_bindings()
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		pcall(function()
			vim.api.nvim_set_option_value("scrollbind", false, { win = w })
			vim.api.nvim_set_option_value("cursorbind", false, { win = w })
		end)
	end
end

local function smart_win(dir, split_cmd)
	local old_win = vim.api.nvim_get_current_win()

	-- 1) Try to move
	vim.cmd("wincmd " .. dir)

	-- 2) If we’re still in the same window, the move failed → split + Oil
	if vim.api.nvim_get_current_win() == old_win then
		vim.cmd(split_cmd)
		vim.cmd("Oil")

		-- 3) As soon as the split (and Oil) is open, clear scrollbind/cursorbind in all panes:
		clear_all_bindings()
	end
end

-- map <leader>{h,j,k,l> to smart_win
local dirs = {
	h = "leftabove vsplit",  -- new window goes to the left
	j = "belowright split",  -- new window goes below
	k = "aboveleft split",   -- new window goes above
	l = "rightbelow vsplit", -- new window goes to the right
}

for key, split_cmd in pairs(dirs) do
	vim.keymap.set("n", "<leader>" .. key, function()
		smart_win(key, split_cmd)
	end, { desc = ("goto or create %s-window"):format(key) })
end

vim.keymap.set("n", "<leader>q", "<C-w>q")

-- Tab movement
vim.keymap.set("n", "<leader>th", "<cmd>-tabmove<CR>")
vim.keymap.set("n", "<leader>tl", "<cmd>+tabmove<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd>Floaterminal<CR>")
vim.keymap.set("n", "<leader>tq", "<cmd>tabclose<CR>")

-- ?
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

-- Page movement
vim.keymap.set("n", "D", "<c-d>zz")
vim.keymap.set("n", "U", "<c-u>zz")

-- Line movement
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- Join lines
vim.keymap.set("n", "J", "mzJ`z")

-- Markdown
vim.keymap.set("v", "<leader>mb", "di****<esc>hhp", { desc = "Auto bold" })
vim.keymap.set("v", "<leader>mi", "di**<esc>hp", { desc = "Auto italic" })
vim.keymap.set("v", "<leader>ml", "di[]()<esc>hhhpllli", { desc = "Auto link" })
vim.keymap.set("v", "<leader>mc", "di``<esc>hp", { desc = "Auto backtick" })

-- Clear
vim.keymap.set("n", "<leader>bw", "<cmd>bufdo bwipeout<cr>", { desc = "Close all buffers" })

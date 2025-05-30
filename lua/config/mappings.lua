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

-- Window selection
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")
vim.keymap.set("n", "<leader>q", "<C-w>q")

-- Tab movement
vim.keymap.set("n", "<leader>th", "<cmd>-tabmove<CR>")
vim.keymap.set("n", "<leader>tl", "<cmd>+tabmove<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd>Floaterminal<CR>")
vim.keymap.set("n", "<leader>tq", "<cmd>tabclose<CR>")

-- ?
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

-- Centering
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

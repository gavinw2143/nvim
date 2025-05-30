vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
	floating = {
		buf = -1,
		win = -1,
	}
}

local function create_floating_window(opts)
	opts              = opts or {}

	-- compute dimensions
	local ui          = vim.api.nvim_list_uis()[1]
	local total_cols  = ui.width
	local total_lines = ui.height
	local width       = opts.width or math.floor(total_cols * 0.8)
	local height      = opts.height or math.floor(total_lines * 0.8)

	-- center
	local row         = math.floor((total_lines - height) / 2)
	local col         = math.floor((total_cols - width) / 2)

	-- create scratch buffer
	local bufnr       = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		bufnr = opts.buf
	else
		bufnr = vim.api.nvim_create_buf(false, true)
	end
	-- build window options
	local win_opts = vim.tbl_extend("force", {
		style    = "minimal",
		relative = "editor",
		row      = row,
		col      = col,
		width    = width,
		height   = height,
		border   = opts.border or "rounded",
	}, opts.win_opts or {})

	-- open the window
	local winnr    = vim.api.nvim_open_win(bufnr, true, win_opts)

	return { buf = bufnr, win = winnr }
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window { buf = state.floating.buf }
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.term()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<space>tt", toggle_terminal)

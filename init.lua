require("core.lazy")
require("config.autocmds")
require("config.mappings")
require("config.options")
vim.opt.clipboard:append("unnamedplus")
local function open_init_tabs()
	-- close all other tabs
	vim.cmd("tabonly")

	local home = vim.loop.os_homedir()
	local dirs = {
		home .. "/.config/nvim"
	}

	for i, dir in ipairs(dirs) do
		if i > 1 then
			vim.cmd("tabnew")
		end

		local short = vim.fn.fnamemodify(dir, ":~")
		-- set the cwd *for this tab* to `dir`
		-- fnameescape handles any spaces/special‐chars
		vim.cmd("tcd " .. vim.fn.fnameescape(short))

		-- now open Oil rooted at the cwd
		local oil = require("oil")
		oil.open(".")
	end
end
open_init_tabs()

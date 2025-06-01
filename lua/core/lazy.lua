-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"nvim-lua/plenary.nvim",
		},
		{
			"folke/tokyonight.nvim",
			opts = {
				transparent = true,
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
			},
			config = function()
				require("tokyonight").setup({
					style = "storm",
					transparent = true,
					styles = {
						sidebars = "transparent",
						floats = "transparent",
					}
				})
				-- Apply the colorscheme
				vim.cmd("colorscheme tokyonight")

				-- 3) Ensure any stray ‘Normal’ or ‘NormalFloat’ highlights don’t paint a bg
				vim.cmd([[ 
  				hi Normal       guibg=NONE ctermbg=NONE
  				hi NormalNC     guibg=NONE ctermbg=NONE
  				hi NormalFloat  guibg=NONE ctermbg=NONE
  				hi EndOfBuffer  guibg=NONE ctermbg=NONE
				]])
			end
		},

		{
			dir = "~/plugins/fast-agent.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				-- Call the setup() function inside fast-agent.lua.
				-- Replace or extend these opts as needed:
				require("fast_agent").setup({
					api_key             = vim.fn.getenv("OPENAI_API_KEY") or "",
					model               = "gpt-3.5-turbo",
					endpoint            = "https://api.openai.com/v1/chat/completions",
					cache_dir           = vim.fn.stdpath("data") .. "/fast_agent",
					use_default_keymaps = true,
				})
				require("fast_agent_ui")
			end,
		},

		{ import = "plugins" },
	},
})

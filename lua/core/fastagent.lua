-- ===================================================================
-- File: lua/core/fastagent.lua
-- Description:
--   Sets up keymaps and helper functions to integrate fast-agent
--   into Neovim. Customize keybindings or functions as you see fit.
-- ===================================================================

local M = {}

-- 1) Helper to create keymaps more concisely
local function nnoremap(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

local function vnoremap(lhs, rhs, desc)
	vim.keymap.set("v", lhs, rhs, { silent = true, desc = desc })
end

-- 2) Open a floating prompt to type a new message
--    Pressing <Enter> will send it to the “current” conversation.
--    If no conversation exists yet, it creates a new one.
function M.open_prompt()
	-- You can pass contextual options if you want, e.g. initial text
	require("fast_agent").open_prompt({
		title = "FastAgent → Type your prompt below:",
		on_submit = function(input_text, convo_id)
			-- Once the user presses <Enter>, input_text is sent automatically,
			-- and convo_id is either the existing conversation or newly created.
			vim.notify("Sending prompt to conversation: " .. convo_id, vim.log.levels.INFO)
			require("fast_agent").send_text(input_text, { conversation = convo_id })
		end,
	})
end

-- 3) Send the visual selection to the agent
function M.send_selection()
	-- Get current visual selection range
	local mode = vim.fn.mode()
	-- Only allow v or V (character or linewise).
	if not (mode == "v" or mode == "V") then
		vim.notify("You must be in visual mode to send text.", vim.log.levels.WARN)
		return
	end

	-- Get start/end positions
	local bufnr                = vim.api.nvim_get_current_buf()
	local start_pos            = vim.api.nvim_buf_get_mark(bufnr, "<") -- {row, col}
	local end_pos              = vim.api.nvim_buf_get_mark(bufnr, ">") -- {row, col}
	local start_row, start_col = start_pos[1], start_pos[2]
	local end_row, end_col     = end_pos[1], end_pos[2]

	-- Extract the text in the range
	local lines                = vim.api.nvim_buf_get_text(bufnr, start_row - 1, start_col, end_row - 1, end_col + 1, {})
	local text                 = table.concat(lines, "\n")

	-- Ask the plugin to send it (to the “current” or specified convo)
	require("fast_agent").send_text(text, {
		-- If your plugin lets you choose a particular conversation, you can
		-- pass something like: conversation = M.choose_conversation()
		-- For now, just send to “current” (the plugin’s default behavior).
	})
end

-- 4) List/switch conversation history
--    (This example uses Telescope to pick one conversation to become “current”)
function M.choose_conversation()
	local fast = require("fast_agent")
	local convos = fast.list_conversations() -- e.g. returns a list of tables
	-- { { id = "abc", name = "Chat #1", last_updated = 123... }, ... }

	local items = {}
	for _, c in ipairs(convos) do
		table.insert(items, {
			display = string.format("%s  (updated: %s)", c.name, os.date("%Y-%m-%d %H:%M", c.last_updated)),
			value   = c.id,
		})
	end

	-- Use Telescope’s built‐in pickers to show the list (requires telescope.nvim)
	require("telescope.pickers").new({}, {
		prompt_title = "FastAgent Conversations",
		finder = require("telescope.finders").new_table({
			results = items,
			entry_maker = function(entry)
				return {
					value = entry.value,
					display = entry.display,
					ordinal = entry.display,
				}
			end,
		}),
		sorter = require("telescope.config").values.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			-- When <Enter> is pressed, set the chosen conversation as “current”
			local select_action = function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				local chosen_id = selection.value
				fast.set_current_conversation(chosen_id)
				vim.notify("Switched to conversation: " .. selection.display, vim.log.levels.INFO)
			end
			map("i", "<CR>", select_action)
			map("n", "<CR>", select_action)
			return true
		end,
	}):find()
end

-- 5) Fetch and store last response in a scratch buffer, with option to append to a file
function M.fetch_and_store()
	local fast = require("fast_agent")
	local current_convo = fast.get_current_conversation_id()
	if not current_convo then
		vim.notify("No active conversation. Open one with <leader>fa first.", vim.log.levels.WARN)
		return
	end

	-- Ask plugin for response asynchronously:
	fast.get_response(current_convo, function(response_text)
		-- 5a) Open a new scratch buffer and insert the response:
		vim.schedule(function()
			vim.cmd("new") -- split
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
			vim.api.nvim_buf_set_option(buf, "swapfile", false)
			vim.api.nvim_buf_set_name(buf, "FastAgent Response")

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response_text, "\n"))

			-- 5b) Optionally: ask the user if they want to append it to a file:
			vim.ui.input({ prompt = "Append this response to file (leave blank to skip): " }, function(input_path)
				if input_path and input_path ~= "" then
					fast.append_to_file(input_path, response_text)
					vim.notify("Appended response to " .. input_path, vim.log.levels.INFO)
				end
			end)
		end)
	end)
end

-- 6) Now map the above functions to your preferred keys:
--    <leader>fa → open a new prompt
--    <leader>fs → send highlighted text (visual mode)
--    <leader>fh → switch conversation
--    <leader>fr → fetch and store last response
function M.setup_keymaps()
	-- replace "<leader>" with your actual leader key (usually "\")
	nnoremap("<leader>fa", M.open_prompt, "FastAgent: Open prompt")
	vnoremap("<leader>fs", M.send_selection, "FastAgent: Send visual selection")
	nnoremap("<leader>fh", M.choose_conversation, "FastAgent: Switch conversation")
	nnoremap("<leader>fr", M.fetch_and_store, "FastAgent: Fetch & store response")
end

-- 7) Expose a setup function to call from user’s init:
function M.setup()
	-- Any plugin‐level setup first (if not done already):
	require("fast_agent").setup({
		-- e.g. model = "gpt-4o-mini", max_tokens = 2048, …
	})
	-- Then keymaps:
	M.setup_keymaps()
end

return M

local db = require("projectmgr.db_adapter")
local helpers = require("projectmgr.helpers")

local api = vim.api
local buf, win
local position = 0

local M = {}

local function set_mappings()
	local mappings = {
		["<cr>"] = 'open_project(require"projectmgr".get_highlighted_name())',
		["x"] = "delete_project()",
		["d"] = "delete_project()",
		["e"] = "update_project()",
		["u"] = "update_project()",
		["a"] = "create_project()",
		["q"] = "close_window()",
		["<ESC>"] = "close_window()",
	}

	for k, v in pairs(mappings) do
		api.nvim_buf_set_keymap(
			buf,
			"n",
			k,
			':lua require"projectmgr".' .. v .. "<cr>",
			{ nowait = true, noremap = true, silent = true }
		)
	end
	local other_chars = {
		"b",
		"c",
		"f",
		"g",
		"i",
		"m",
		"n",
		"o",
		"p",
		"r",
		"s",
		"t",
		"v",
		"w",
		"y",
		"z",
	}
	for _, v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

local function create_view()
	buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", "projectmgr")

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(20)
	local win_width = math.ceil(35)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
	}

	win = api.nvim_open_win(buf, true, opts)
	api.nvim_win_set_option(win, "cursorline", true)

	api.nvim_buf_set_lines(buf, 0, -1, false, { " [Projects]", "", "" })
	api.nvim_buf_add_highlight(buf, -1, "ProjectmgrHeader", 0, 0, -1)

	set_mappings()
end

local function update_view(direction)
	api.nvim_buf_set_option(buf, "modifiable", true)
	position = position + direction
	if position < 1 then
		position = 1
	end
	local count_entries = 0

	local flattened = db.get_projects()
	for k, _ in pairs(flattened) do
		flattened[k] = "  " .. flattened[k]
		count_entries = count_entries + 1
	end

	api.nvim_buf_set_lines(buf, 3, -1, false, flattened)
	api.nvim_buf_set_option(buf, "modifiable", false)

	if count_entries > 0 then
		api.nvim_win_set_cursor(win, { 4, 0 })
	end
end

function M.open_window()
	position = 0
	create_view()
	update_view(0)
end

function M.close_window()
	if win ~= nil then
		api.nvim_win_close(win, true)
	end
end

function M.create_project()
	M.close_window()
	db.create_project()

	create_view()
	update_view(0)
end

function M.update_project()
	local old_name = helpers.get_highlighted_name()
	local old_pos = api.nvim_win_get_cursor(0)

	M.close_window()
	db.update_project(old_name)

	create_view()
	update_view(0)
	api.nvim_win_set_cursor(win, old_pos)
end

function M.delete_project()
	db.delete_project(helpers.get_highlighted_name())
	update_view(0)
end

M.win = win
return M

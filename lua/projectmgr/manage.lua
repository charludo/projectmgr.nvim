local api = vim.api
local db = require("projectmgr.db_adapter")
local helpers = require("projectmgr.helpers")
local window = require("projectmgr.window")

local M = {}

function M.open_project(name)
	local path, command, _ = db.get_single_project(name)

	if path == nil then
		return
	end

	window.close_window()
	M.close_project()

	api.nvim_command("cd " .. path)

	if M.config.autogit then
		helpers.autogit()
	end

	if M.config.session.enabled and helpers.file_exists(M.config.session.file) then
		api.nvim_command("so " .. M.config.session.file)
	end

	if M.config.shada.enabled and helpers.file_exists(M.config.shada.file) then
		api.nvim_command("rshada " .. M.config.shada.file)
	end

	helpers.execute_script(M.config.scripts.file_startup)
	if command ~= "" then
		helpers.execute_command(command)
	end

	db.set_current_project(name)
end

function M.close_project()
	local name_from_path = db.is_in_project()
	db.set_current_project(name_from_path)

	if name_from_path == nil then
		return
	end

	local _, _, command = db.get_single_project(name_from_path)

	if M.config.session.enabled then
		vim.api.nvim_exec(
			[[
					for l in range(1, bufnr('$'))
					if bufexists(l) && !buflisted(l)
					silent! exec 'bd ' . l
					endif
					endfor
					]],
			false
		)

		api.nvim_command("set sessionoptions-=options")
		api.nvim_command("mksession! " .. M.config.session.file)
	end

	if M.config.shada.enabled then
		api.nvim_command("wshada! " .. M.config.shada.file)
	end

	helpers.execute_script(M.config.scripts.file_shutdown)
	if command ~= "" then
		helpers.execute_command(command)
	end

	api.nvim_command("bufdo bd")
end

return M

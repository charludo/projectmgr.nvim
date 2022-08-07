local db = require("projectmgr.db_adapter")
local window = require("projectmgr.window")
local manage = require("projectmgr.manage")

local M = {}

local default_config = {
	autogit = false,
	reopen = false,
	session = { enabled = true, file = "Session.vim" },
	shada = { enabled = false, file = "main.shada" },
	scripts = {
		enabled = true,
		file_startup = "startup.sh",
		file_shutdown = "shutdown.sh",
	},
}

function M.setup(config)
	config = config or {}
	vim.validate({
		autogit = { config.autogit, "b", true },
		reopen = { config.reopen, "b", true },
		session = { config.session, "t", true },
		shada = { config.shada, "t", true },
		scripts = { config.scripts, "t", true },
	})

	M.config = vim.tbl_extend("keep", config, default_config)
	manage.config = M.config

	vim.api.nvim_exec(
		[[
        augroup ProjectMgrGroup
            autocmd!
            autocmd VimEnter * lua require("projectmgr").startup()
            autocmd VimLeavePre * lua require("projectmgr").shutdown()
        augroup END
    ]],
		false
	)
end

function M.startup()
	db.prepare_db()
	if M.config.reopen then
		local current = db.get_current_project()
		if current == nil then
			current = "-1"
		end
		manage.open_project(current)
	end
end

function M.shutdown()
	manage.close_project()
end

M.open_project = manage.open_project
M.close_project = manage.close_project

M.open_window = window.open_window
M.close_window = window.close_window
M.create_project = window.create_project
M.update_project = window.update_project
M.delete_project = window.delete_project

return M

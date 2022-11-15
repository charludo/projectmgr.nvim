local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local previewers = require("telescope.previewers")
local config = require("telescope.config")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local manage = require("projectmgr.manage")
local db = require("projectmgr.db_adapter")
local helpers = require("projectmgr.helpers")

local M = {}

local show_telescope = function(opts)
	local projects = db.get_projects()
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Projects",
			finder = finders.new_table(projects),
			sorter = config.values.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Config & Info",
				define_preview = function(self, entry, status)
					local path, start, stop = db.get_single_project(entry.value)
					local current, tracking = helpers.git_info(path)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
						"    project path: " .. path,
						" startup command: " .. helpers.symbolize(start),
						"shutdown command: " .. helpers.symbolize(stop),
						-- "",
						-- "startup script: " .. symbolize(helpers.file_exists(M.config.scripts.file_startup)),
						-- "shutdown script:",
						"",
						" active git repo: " .. helpers.symbolize(helpers.check_git(path)),
						"  current branch: " .. current,
						" tracking remote: " .. tracking,
					})

					for i = 0, 12 do
						vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "@comment", i, 0, 18)
					end
				end,
			}),

			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					manage.open_project(selection.value)
				end)
				map({ "i", "n" }, "<C-e>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.update_project(selection.value)
					M.open_picker()
				end)
				map({ "i", "n" }, "<C-u>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.update_project(selection.value)
					M.open_picker()
				end)
				map({ "i", "n" }, "<C-x>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.delete_project(selection.value)
					M.open_picker()
				end)
				map({ "i", "n" }, "<C-d>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.delete_project(selection.value)
					M.open_picker()
				end)
				map({ "i", "n" }, "<C-a>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					db.create_project()
					M.open_picker()
				end)

				return true
			end,
		})
		:find()
end

function M.open_picker()
	show_telescope()
end

return M

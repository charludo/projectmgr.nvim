local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local config = require("telescope.config")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local manage = require("projectmgr.manage")
local db = require("projectmgr.db_adapter")

local M = {}

-- our picker function: colors
local show_telescope = function(opts)
	local projects = db.get_projects()
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Projects",
			finder = finders.new_table(projects),
			sorter = config.values.generic_sorter(opts),
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
					builtin.resume()
				end)
				map({ "i", "n" }, "<C-u>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.update_project(selection.value)
					builtin.resume()
				end)
				map({ "i", "n" }, "<C-x>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.delete_project(selection.value)
					builtin.resume()
				end)
				map({ "i", "n" }, "<C-d>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					local selection = action_state.get_selected_entry()
					db.delete_project(selection.value)
					builtin.resume()
				end)
				map({ "i", "n" }, "<C-a>", function(_prompt_bufnr)
					actions.close(_prompt_bufnr)
					db.create_project()
					builtin.resume()
				end)

				return true
			end,
		})
		:find()
end

-- to execute the function
function M.open_picker()
	show_telescope()
end

return M

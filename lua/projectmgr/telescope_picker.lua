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

local clean = function(input)
	if input == nil or input:gsub("%s+", "") == "" then
		return "✗"
	end
	return input
end

local symbolize = function(b_value)
	if b_value then
		return "✓"
	else
		return "✗"
	end
end

local trim = function(str)
	str = str:gsub("[\n\r]", " ")
	return str
end

local git_info = function(path)
	if not helpers.check_git(path) then
		return "✗", "✗", "✗"
	end
	local main_branch = trim(
		vim.api.nvim_command_output(
			"!git --git-dir " .. path .. "/.git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'"
		)
	)
	local current_branch =
		trim(vim.api.nvim_command_output("!git --git-dir " .. path .. "/.git rev-parse --abbrev-ref HEAD"))
	local tracking_branch = trim(
		vim.api
			.nvim_command_output("!git --git-dir " .. path .. "/.git rev-parse --abbrev-ref --symbolic-full-name @{u}")
			:gsub("[ \t]+%f[\r\n%z]", "")
	)

	return main_branch, current_branch, tracking_branch
end

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
					local main, current, tracking = git_info(path)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
						"    project path: " .. path,
						" startup command: " .. clean(start),
						"shutdown command: " .. clean(stop),
						-- "",
						-- "startup script: " .. symbolize(helpers.file_exists(M.config.scripts.file_startup)),
						-- "shutdown script:",
						"",
						" active git repo: " .. symbolize(helpers.check_git(path)),
						"     main branch: " .. main,
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

function M.open_picker()
	show_telescope()
end

return M

-- Imports the module for handling SQLite.
local sqlite = require("lsqlite3")
local db_path =
	string.match(debug.getinfo(1, "S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")
-- Creates an object for the module.
local M = {}

-- Fetches projects tasks from the database and
-- prints the output.
function M.get_projects()
	local db = sqlite.open(db_path)

	local results = {}

	for i in db:nrows("SELECT * FROM projects ORDER BY name;") do
		table.insert(results, i.name)
	end

	db:close()
	return results
end

function M.get_current_project()
	local db = sqlite.open(db_path)

	local name = nil

	for i in db:nrows("SELECT name FROM projects WHERE current=='1';") do
		name = i.name
	end

	db:close()

	return name
end

function M.is_in_project()
	local db = sqlite.open(db_path)

	local is_in = false

	local pwd = vim.fn.getcwd()
	for _ in db:nrows("SELECT name FROM projects WHERE instr(path, '" .. pwd .. "');") do
		is_in = true
	end

	db:close()

	return is_in
end

function M.get_single_project(name)
	if name == nil then
		return nil, nil, nil
	end
	local db = sqlite.open(db_path)

	local path, commandstart, commandexit = nil, nil, nil

	for i in db:nrows("SELECT path, commandstart, commandexit FROM projects WHERE name=='" .. name .. "';") do
		path, commandstart, commandexit = i.path, i.commandstart, i.commandexit
	end

	db:close()

	return path, commandstart, commandexit
end

return M

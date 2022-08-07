local sqlite = require("lsqlite3")
local db_path =
	string.match(debug.getinfo(1, "S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")

local M = {}

function M.prepare_db()
	local db = sqlite.open(db_path)
	db:exec(
		"create table IF NOT EXISTS projects(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, path TEXT NOT NULL, commandstart TEXT, commandexit TEXT, current INTEGER DEFAULT '0' NOT NULL);"
	)

	local count = nil
	for i in db:nrows("SELECT COUNT(*) AS CNTREC FROM pragma_table_info('projects') WHERE name='commandstart';") do
		count = i.CNTREC
	end
	if count == 0 then
		db:exec("ALTER TABLE projects RENAME COLUMN command TO commandstart;")
		db:exec("ALTER TABLE projects ADD commandexit TEXT;")
		db:exec("ALTER TABLE projects ADD current INTEGER DEFAULT '0' NOT NULL;")
	end
	db:close()
end

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

function M.set_current_project(name)
	local db = sqlite.open(db_path)
	print(name)
	local _ = db:exec("UPDATE projects SET current='0';")
	db:close()

	db = sqlite.open(db_path)
	local _ = db:exec("UPDATE projects SET current='1' WHERE name=='" .. name .. "';")
	db:close()
end

function M.create_project()
	local name
	repeat
		name = vim.fn.input("Project Name: ")
		print("")
	until (name ~= "") and (string.len(name) <= 150)

	local path
	repeat
		path = vim.fn.input({
			prompt = "Project Path: ",
			completion = "file_in_path",
		})
		print("")
	until (path ~= "") and (string.len(path) <= 150)

	local commandstart
	commandstart = vim.fn.input({
		prompt = "Startup Command (opional): ",
		completion = "file_in_path",
	})

	local commandexit
	commandexit = vim.fn.input({
		prompt = "Exit Command (optional): ",
		completion = "file_in_path",
	})

	local db = sqlite.open(db_path)
	local _ = db:exec(
		"INSERT INTO projects (name, path, commandstart, commandexit) VALUES ('"
			.. name
			.. "', '"
			.. path
			.. "', '"
			.. commandstart
			.. "', '"
			.. commandexit
			.. "');"
	)
	db:close()

	vim.api.nvim_command(
		"echo '\r Created new project.                                                                                                                        '"
	)
end

function M.update_project(old_name)
	local old_path, old_commandstart, old_commandexit = M.get_single_project(old_name)
	local name
	repeat
		name = vim.fn.input("Project Name: ", old_name)
		print("")
	until (name ~= "") and (string.len(name) <= 150)

	local path
	repeat
		path = vim.fn.input({
			prompt = "Project Path: ",
			default = old_path,
			completion = "file_in_path",
		})
		print("")
	until (path ~= "") and (string.len(path) <= 150)

	local commandstart
	commandstart = vim.fn.input({
		prompt = "Startup Command (opional): ",
		default = old_commandstart,
		completion = "file_in_path",
	})

	local commandexit
	commandexit = vim.fn.input({
		prompt = "Exit Command (optional): ",
		default = old_commandexit,
		completion = "file_in_path",
	})

	local db = sqlite.open(db_path)
	local _ = db:exec(
		"UPDATE projects SET name='"
			.. name
			.. "', path='"
			.. path
			.. "', commandstart='"
			.. commandstart
			.. "', '"
			.. commandexit
			.. "' WHERE name=='"
			.. old_name
			.. "';"
	)
	db:close()

	vim.api.nvim_command(
		"echo '\r Updated project.                                                                                                                         '"
	)
end

function M.delete_project(name)
	local db = sqlite.open(db_path)

	db:exec("DELETE FROM projects WHERE name == '" .. name .. "';")
	db:close()
end

return M

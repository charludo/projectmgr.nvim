local helpers = require("projectmgr.helpers")

local db_path =
	string.match(debug.getinfo(1, "S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.json")

local function read_db()
	local file = io.open(db_path, "rb")
	if not file then
		return {}
	end
	local data = file:read("*all")
	file:close()

	return vim.json.decode(data)
end

local function write_db(data)
	local data_cleaned = {}
	for _, v in pairs(data) do
		if v ~= nil then
			table.insert(data_cleaned, v)
		end
	end

	local file = io.open(db_path, "w")
	if not file then
		return
	end
	file:write(vim.json.encode(data_cleaned))
	file:close()
end

local M = {}

function M.get_projects()
	local data = read_db()
	local names = {}
	for _, v in pairs(data) do
		table.insert(names, v.name)
	end
	table.sort(names)
	return names
end

function M.set_current_project(name)
	local data = read_db()
	for k, v in pairs(data) do
		if v.name == name then
			data[k].current = 1
		else
			data[k].current = 0
		end
	end
	write_db(data)
end

function M.get_current_project()
	local data = read_db()
	for _, v in pairs(data) do
		if v.current == 1 then
			return v.name
		end
	end
end

function M.is_in_project()
	local data = read_db()
	local pwd = vim.fn.getcwd()
	for _, v in pairs(data) do
		local stem = v.path:sub(2, -2)
		if pwd:find(stem, 1, true) then
			return v.name
		end
	end
	return nil
end

function M.get_single_project(name)
	local data = read_db()
	for _, v in pairs(data) do
		if v.name == name then
			return v.path, v.commandstart, v.commandexit
		end
	end
	return nil, nil, nil
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

	local new_project =
		{ name = name, path = path, commandstart = commandstart, commandexit = commandexit, current = 0 }

	local data = read_db()
	table.insert(data, new_project)
	write_db(data)

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

	local was_current = old_name == M.get_current_project()

	local updated_project =
		{ name = name, path = path, commandstart = commandstart, commandexit = commandexit, current = was_current }

	local data = read_db()
	for k, v in pairs(data) do
		if v.name == old_name then
			data[k] = updated_project
			break
		end
	end
	write_db(data)

	vim.api.nvim_command(
		"echo '\r Updated project.                                                                                                                         '"
	)
end

function M.delete_project(name)
	local data = read_db()
	for k, v in pairs(data) do
		if v.name == name then
			data[k] = nil
			break
		end
	end
	write_db(data)
end

function M.migrate_if_necessary()
	local old_db_path =
		string.match(debug.getinfo(1, "S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")
	if not helpers.file_exists(old_db_path) then
		return
	end

	-- SQLite DB still exists - dump it into JSON and delete it
	local sqlite = require("lsqlite3complete")
	local db = sqlite.open(old_db_path)
	local data = {}
	for i in db:nrows("SELECT * FROM projects;") do
		table.insert(data, {
			name = i.name,
			path = i.path,
			commandstart = i.commandstart,
			commandexit = i.commandexit,
			current = tonumber(i.current),
		})
	end
	db:close()

	write_db(data)
	os.rename(old_db_path, old_db_path .. ".bak")
end

return M

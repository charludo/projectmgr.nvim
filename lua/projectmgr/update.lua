-- Imports the module for handling SQLite.
local fetch = require("projectmgr.fetch")

local sqlite = require("ljsqlite3")
local db_path = string.match(debug.getinfo(1,"S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")
-- Creates an object for the module.
local M = {}

-- Inserts a new project, prompting the
-- user to enter relevant data.
function M.create_project()
    local name = ""
    repeat
        name = vim.fn.input("Project Name: ")
        print("")
    until (name ~= "") and (string.len(name) <= 150)

    local path = ""
    repeat
        path = vim.fn.input("Project Path: ")
        print("")
    until (path ~= "") and (string.len(path) <= 150)

    local command = ""
    command = vim.fn.input("Startup Command (opional): ")
    print("Create new project.")

    local db = sqlite.open(db_path)
    db:exec("INSERT INTO projects (name, path, command) VALUES ('" .. name .. "', '" .. path .. "', '" .. command .. "');")
    db:close()
end

function M.update_project(old_name)
    local old_path, old_command = fetch.get_single_project(old_name)
    local name = ""
    repeat
        name = vim.fn.input("Project Name: ", old_name)
        print("")
    until (name ~= "") and (string.len(name) <= 150)

    local path = ""
    repeat
        path = vim.fn.input("Project Path: ", old_path)
        print("")
    until (path ~= "") and (string.len(path) <= 150)

    local command = ""
    command = vim.fn.input("Startup Command (opional): ", old_command)
    print("Updated project.")

    local db = sqlite.open(db_path)
    db:exec("UPDTAE projects SET name='"..name.."', path='"..path.."', command='"..command.."' WHERE name=='"..old_name.."' LIMIT 1;")
    db:close()
end


-- Deletes a project.
function M.delete_project(name)
    local db = sqlite.open(db_path)

    db:exec("DELETE FROM projects WHERE name == '" .. name .. "';")
    db:close()
end

return M

-- Imports the module for handling SQLite.
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
    print("")

    local db = sqlite.open(db_path)
    db:exec("INSERT INTO projects (name, path, command) VALUES ('" .. name .. "', '" .. path .. "', '" .. command .. "');")
    db:close()
end

-- Deletes a project.
function M.delete_project(name)
    local db = sqlite.open(db_path)

    db:exec("DELETE FROM projects WHERE name == '" .. name .. "';")
    db:close()
end

return M

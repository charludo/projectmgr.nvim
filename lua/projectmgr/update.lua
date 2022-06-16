-- Imports the module for handling SQLite.
local sqlite = require("ljsqlite3")

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

    local db = sqlite.open("projects.db")
    db:exec("INSERT INTO projects (name, path, command) VALUES (''" .. name .. "', '" .. path .. "', '" .. command .. "');")
    db:close()
end

-- Deletes a project.
function M.delete_project()
    local db = sqlite.open("projects.db")

    local project_to_delete = -1
    local project_selected = -1
    repeat
        local db_results = db:exec("SELECT * FROM projects;")
        for i, item in ipairs(db_results[2]) do
            print(tostring(db_results[1][i]) .. ': ' .. item)
        end

        project_selected = tonumber(vim.fn.input("ID of project to delete: "))

        for _, id in ipairs(db_results[1]) do
            if (id == project_selected) then project_to_delete = project_selected end
        end

        print("")
    until project_selected >= 0

    db:exec("DELETE FROM projects WHERE id = " .. project_to_delete .. ";")
    db:close()
end

return M

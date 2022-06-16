-- Imports the module for handling SQLite.
local sqlite = require("ljsqlite3")

-- Creates an object for the module.
local M = {}

-- Fetches projects tasks from the database and
-- prints the output.
function M.get_projects()
    local db = sqlite.open("projects.db")

    local db_results, nrow = db:exec("SELECT * FROM projects;")

    local results = {}

    for i=1, nrow do
        results[i] = db_results.name[i]
    end

    db:close()
    return results
end

function M.get_single_project(name)
    local db = sqlite.open("projects.db")
    local path, command = db:rowexec("SELECT path, command FROM projects WHERE name=='"..name.."';")
    return path, command
end

return M

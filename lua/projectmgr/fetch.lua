-- Imports the module for handling SQLite.
local sqlite = require("lsqlite3")
local db_path = string.match(debug.getinfo(1,"S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")
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

function M.get_single_project(name)
    local db = sqlite.open(db_path)
    local result = db:nrows("SELECT path, command FROM projects WHERE name=='"..name.."';")[1]
    return result.path, result.command
end

return M

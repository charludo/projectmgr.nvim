-- Imports the module for handling SQLite.
local sqlite = require("ljsqlite3")

-- Creates an object for the module.
local M = {}

-- Fetches projects tasks from the database and
-- prints the output.
function M.fetch_todos()
    local db = sqlite.open("projects.db")

    local db_results = db:exec("SELECT * FROM projects;")
    for _, item in ipairs(db_results[2]) do print(item) end

    db:close()
end

return M

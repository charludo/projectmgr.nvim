-- Imports the module for handling SQLite.
local sqlite = require("ljsqlite3")

-- Creates an object for the module.
local M = {}

-- Fetches projects tasks from the database and
-- prints the output.
function M.get_projects()
    local db = sqlite.open("projects.db")

    local db_results = db:exec("SELECT * FROM projects;")
    for k, item in ipairs(db_results[1]) do print(k .. ' ' .. item) end
    for k, item in ipairs(db_results[2]) do print(k .. ' ' .. item) end
    for k, item in ipairs(db_results[3]) do print(k .. ' ' .. item) end
    print(db_results)
    db:close()
    return db_results
end
-- print(M.get_projects())
return M

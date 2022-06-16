-- Imports the module for handling SQLite.
local sqlite = require("ljsqlite3")

-- Creates an object for the module.
local M = {}

-- Fetches projects tasks from the database and
-- prints the output.
function M.get_projects()
    local db = sqlite.open("projects.db")

    local db_results, nrow = db:exec("SELECT * FROM projects;")

    -- local results = {}
    -- for k, item in ipairs(db_results[1]) do print(k .. ' ' .. item) end
    -- for k, item in ipairs(db_results.name) do results[k] = item end
    -- for k, item in ipairs(db_results[4]) do print(k .. ' ' .. item) end
    -- print(results)

    for i=1, nrow do
        print(db_results.name[i] .. db_results.id[i])
    end

    db:close()
    return db_results
end
-- print(M.get_projects())
return M

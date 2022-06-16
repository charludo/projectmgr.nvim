local sqlite = require("ljsqlite3")

local M = {}

function M.switch_project()
    local db = sqlite.open("projects.db")

    local db_results = db:exec("SELECT * FROM projects;")
    for _, item in ipairs(db_results[2]) do print(item) end

    db:close()
end

return M

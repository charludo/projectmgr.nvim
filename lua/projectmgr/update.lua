-- Imports the module for handling SQLite.
local fetch = require("projectmgr.fetch")

local sqlite = require("lsqlite3")
local db_path = string.match(debug.getinfo(1,"S").source, "^@(.+/)[%a%-%d_]+%.lua$"):gsub("lua/projectmgr/", "projects.db")
-- Creates an object for the module.
local M = {}

function M.prepare_db()
    local db = sqlite.open(db_path)
    db:exec("create table IF NOT EXISTS projects(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, path TEXT NOT NULL, commandstart TEXT, commandexit TEXT, current INTEGER DEFAULT '0' NOT NULL);")

    -- check if table is in new format; if not, migrate
    local count = nil
    for i in db:nrows("SELECT COUNT(*) AS CNTREC FROM pragma_table_info('projects') WHERE name='commandstart';") do
        count = i.CNTREC
    end
    if count == 0 then
        db:exec("ALTER TABLE projects RENAME COLUMN command TO commandstart;")
        db:exec("ALTER TABLE projects ADD commandexit TEXT;")
        db:exec("ALTER TABLE projects ADD current INTEGER DEFAULT '0' NOT NULL;")
    end
    db:close()
end

function M.set_current_project(name)
    local db = sqlite.open(db_path)
    -- local _ = db:exec("UPDATE projects SET current=0;")
    -- db:close()

    -- db = sqlite.open(db_path)
    local _ = db:exec("UPDTAE projects SET current=1 WHERE name=='"..name.."';")
    db:close()
end

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

    local commandstart = ""
    commandstart = vim.fn.input("Startup Command (opional): ")

    local commandexit = ""
    commandexit = vim.fn.input("Exit Command (optional): ")

    local db = sqlite.open(db_path)
    local _ = db:exec("INSERT INTO projects (name, path, commandstart, commandexit) VALUES ('" .. name .. "', '" .. path .. "', '" .. commandstart .. "', '" .. commandexit .. "');")
    db:close()

    vim.api.nvim_command("echo '\r Created new project.                                                                                                                        '")
end

function M.update_project(old_name)
    local old_path, old_commandstart, old_commandexit = fetch.get_single_project(old_name)
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

    local commandstart = ""
    commandstart = vim.fn.input("Startup Command (opional): ", old_commandstart)

    local commandexit = ""
    commandexit = vim.fn.input("Exit Command (optional): ", old_commandexit)

    local db = sqlite.open(db_path)
    local _ = db:exec("UPDATE projects SET name='"..name.."', path='"..path.."', commandstart='"..commandstart.."', '" ..commandexit.. "' WHERE name=='"..old_name.."';")
    db:close()

    vim.api.nvim_command("echo '\r Updated project.                                                                                                                         '")
end


-- Deletes a project.
function M.delete_project(name)
    local db = sqlite.open(db_path)

    db:exec("DELETE FROM projects WHERE name == '" .. name .. "';")
    db:close()
end

return M

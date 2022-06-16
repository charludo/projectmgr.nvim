-- Imports the plugin's additional Lua modules.
local switch = require("projectmgr.switch")
local fetch = require("projectmgr.fetch")
local update = require("projectmgr.update")

-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.
local M = {}

-- Routes calls made to this module to functions in the
-- plugin's other modules.
M.switch_project = switch.switch_project
M.get_projects = fetch.get_projects
M.create_project = update.create_project
M.delete_project = update.delete_project

return M

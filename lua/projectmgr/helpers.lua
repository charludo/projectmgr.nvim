local api = vim.api

local M = {}

function M.file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function M.get_highlighted_name()
	local str = api.nvim_get_current_line()
	local name = str:match("^%s*(.*)")
	return name
end

function M.execute_command(command)
	if command == nil then
		return
	end
	if command:find("^!") ~= nil then
		local _ = io.popen(string.sub(command, 2))
	else
		api.nvim_command(command)
	end
end

function M.execute_script(filename)
	if M.file_exists(filename) then
		local _ = io.popen("./" .. filename)
	end
end

return M

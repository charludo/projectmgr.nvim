local api = vim.api

local M = {}

function M.file_exists(name)
	if name == nil then
		return false
	end
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

function M.autogit()
	local is_git = false
	local handle = io.popen("git rev-parse --is-inside-work-tree")
	if handle ~= nil then
		local check_result = handle:read("*a")
		if string.find(check_result, "true") then
			is_git = true
		end
		handle:close()
	end

	if is_git then
		local _ = io.popen("git fetch && git pull")
		print("[ProjectMgr] git repo found, fetching && pulling...")
	end
end

return M

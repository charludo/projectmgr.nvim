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

function M.trim(str)
	str = str:gsub("[\n\r]", " ")
	return str
end

function M.remove_trailing_slash(str)
	str = str:gsub("(.*)/$", "%1")
	return str
end

function M.call_ext(command)
	local handle = io.popen(command)
	if handle ~= nil then
		local result = handle:read("*a")
		handle:close()
		return M.trim(result)
	end
	return nil
end

function M.check_git(path)
	local is_git = false
	local handle =
		io.popen("git -C '" .. M.remove_trailing_slash(path) .. "' rev-parse --is-inside-work-tree 2>/dev/null")
	if handle ~= nil then
		local check_result = handle:read("*a")
		if string.find(check_result, "true") then
			is_git = true
		end
		handle:close()
	end
	return is_git
end

function M.autogit(command)
	if M.check_git(".") then
		local _ = io.popen(command)
		print("[ProjectMgr] git repo found, pulling...")
	end
end

function M.symbolize(value)
	if type(value) == "string" then
		if value:gsub("%s+", "") ~= "" then
			return value
		end
		value = false
	end
	if value then
		return "✓"
	else
		return "✗"
	end
end

function M.git_info(path)
	if not M.check_git(path) then
		return "✗", "✗", "✗"
	end
	local current_branch =
		M.call_ext("git -C '" .. M.remove_trailing_slash(path) .. "/.git' rev-parse --abbrev-ref HEAD 2>/dev/null")
	local tracking_branch = M.call_ext(
		"git -C '"
			.. M.remove_trailing_slash(path)
			.. "/.git' rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null"
	)

	return M.symbolize(current_branch), M.symbolize(tracking_branch)
end

return M

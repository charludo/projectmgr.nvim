local WIN32 = {}

local IS_POWERSHELL = vim.o.shell:find("powershell.exe")
local IS_CMD = vim.o.shell:find("cmd.exe")

function WIN32.remove_trailing_slash(str)
	str = str:gsub("(.*)\\$", "%1")
	str = str:gsub("\\ ", " ")
	return str
end

function WIN32.add_shell_ending(cmd)
	if IS_POWERSHELL then
		return cmd .. " 2>$null"
	elseif IS_CMD then
		return cmd .. " 2> NUL"
	else
		vim.notify("Uknown windows shell")
		return cmd
	end
end

function WIN32.inside_tree_cmd(path)
	local cmd_string = "git -C \"" ..
			WIN32.remove_trailing_slash(path) .. "\" rev-parse --is-inside-work-tree"

	return WIN32.add_shell_ending(cmd_string)
end

function WIN32.get_git_branch(path)
	local cmd_string = "git -C \"" ..
		WIN32.remove_trailing_slash(path) .. "\\.git\" rev-parse --abbrev-ref HEAD"

	return WIN32.add_shell_ending(cmd_string)
end

function WIN32.get_tracking_branch(path)
	local cmd_string = "git -C \"" .. WIN32.remove_trailing_slash(path)
		.. "\\.git\" rev-parse --abbrev-ref --symbolic-full-name @{u}"

	return WIN32.add_shell_ending(cmd_string)
end

return WIN32

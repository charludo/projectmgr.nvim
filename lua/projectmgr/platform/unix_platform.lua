local UNIX = {}

function UNIX.remove_trailing_slash(str)
	str = str:gsub("(.*)/$", "%1")
	return str
end

function UNIX.inside_tree_cmd(path)
	return "git -C '" .. UNIX.remove_trailing_slash(path) ..
	  "' rev-parse --is-inside-work-tree 2>/dev/null"
end

function UNIX.get_git_branch(path)
	return "git -C '" .. UNIX.remove_trailing_slash(path) ..
	  "/.git' rev-parse --abbrev-ref HEAD 2>/dev/null"
end

function UNIX.get_tracking_branch(path)
	return "git -C '" .. UNIX.remove_trailing_slash(path)
		.. "/.git' rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null"
end

return UNIX


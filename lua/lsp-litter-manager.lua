-- @brief Find the project's root absolute path.
--
-- If the project is tracked by git then the directory in which .git is located
-- is considered the root of the project. Otherwise, if .git isn't found, then
-- the current working directory is considered the project's root.
--
-- @return The project's root absolute path.
local function find_project_root()
	local function is_git_repo()
		vim.fn.system("git rev-parse --is-inside-work-tree")
		return vim.v.shell_error == 0
	end

	local function get_git_root()
		local dot_git_path = vim.fn.finddir(".git", ".;")
		return vim.fn.fnamemodify(dot_git_path, ':p:h:h')
	end

	if is_git_repo() then
		return get_git_root()
	else
		return vim.fn.getcwd()
	end
end

-- @brief Get the project's mapped directory, which contains its metadata.
--
-- @param project_root The absolute path to the project.
--
-- @return The absolute path to the project's mapped directory.
function get_project_mapped_dir()
	local project_root = find_project_root()

	-- We need to escape @ characters in the file path so that if another
	-- project uses @ characters, the two projects won't share mapped dir.
	local escaped = string.gsub(project_root, "@", "@@")
	-- Replace the directory delimiters '/' with '@'
	escaped = string.gsub(escaped, "/", "@")
	-- The absolute path to the mapped directory.
	local mapped_dir = vim.fn.stdpath('data') .. '/mapped/' .. escaped

	-- We need to create the directory if it doesn't exist.
	local function does_dir_exist(dirpath)
		local success, errmsg = os.rename(dirpath, dirpath)
		if not success then
			if errmsg:find("No such file or directory") then
				return false
			end
		end

		return true
	end

	if not does_dir_exist(mapped_dir) then
		os.execute("mkdir " .. mapped_dir)
	end

	return mapped_dir
end

return {
	get_project_mapped_dir = get_project_mapped_dir
}

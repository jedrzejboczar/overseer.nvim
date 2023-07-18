local files = require("overseer.files")
local util = require("overseer.util")
local M = {}

---Get the primary language for the workspace
---TODO this is VERY incomplete at the moment
---@return string|nil
M.get_workspace_language = function()
  if files.any_exists("setup.py", "setup.cfg", "pyproject.toml", "mypy.ini") then
    return "python"
  elseif files.any_exists("tsconfig.json") then
    return "typescript"
  elseif files.any_exists("package.json") then
    return "javascript"
  end
  -- TODO java
  -- TODO powershell
end

-- First has higher priority
local tasks_files = {
  "tasks.json",
}
if util.has_yaml_decoder() then
    table.insert(tasks_files, 1, "tasks.yaml")
end

---@param dir string
---@return nil|string
M.get_tasks_file = function(dir)
  local vscode_dirs =
    vim.fs.find(".vscode", { upward = true, type = "directory", path = dir, limit = math.huge })
  for _, vscode_dir in ipairs(vscode_dirs) do
    for _, file in ipairs(tasks_files) do
      local path = files.join(vscode_dir, file)
      if files.exists(path) then
        return path
      end
    end
  end
end

---@param dir string
---@return table
M.load_tasks_file = function(dir)
  local tasks_file = M.get_tasks_file(dir)
  local ext = files.get_extension(tasks_file)
  if ext == "json" then
    return files.load_json_file(tasks_file)
  elseif ext == "yaml" then
    return files.load_yaml_file(tasks_file)
  else
      error(string.format("Unsupported tasks file extension '%s': %s", ext, tasks_file))
  end
end

return M

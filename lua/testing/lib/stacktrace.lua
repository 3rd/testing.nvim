---@class StackTrace
---@field path string
---@field line number | nil
---@field context "main" | "Lua" | "C" | "tail"
---@field kind "global" | "local" |  "field" | "method" | "upvalue" | ""
---@field function_name string | nil
---@field function_declaration_first_line number | nil
---@field function_declaration_last_line number | nil

---@param level? number
---@return StackTrace
local get_stack_trace = function(level)
  local info = debug.getinfo((level or 0) + 2, "Snful")

  return {
    path = vim.startswith(info.source, "@") and info.source:sub(2) or nil,
    line = info.currentline,
    context = info.what,
    kind = info.namewhat,
    function_name = info.name,
    function_declaration_first_line = info.linedefined,
    function_declaration_last_line = info.lastlinedefined,
  }
end

return {
  get_stack_trace = get_stack_trace,
}

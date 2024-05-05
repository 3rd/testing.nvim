---@vararg string|string[]
---@return string
local resolve = function(...)
  local args = { ... }
  local path = table.concat(args, "/")
  return vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
end

return {
  resolve = resolve,
}

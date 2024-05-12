local format_indent = function(str, level)
  local insert = string.rep(" ", (level or 2))
  return insert .. str:gsub("\n(%S)", "\n" .. insert .. "%1")
end

local escape = function(str)
  return str:gsub("%%", "%%%%")
end

return {
  format_indent = format_indent,
  escape = escape,
}

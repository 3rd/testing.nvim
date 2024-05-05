local format_indent = function(str, level)
  local insert = string.rep(" ", (level or 2))
  return insert .. str:gsub("\n", "\n" .. insert)
end

return {
  format_indent = format_indent,
}

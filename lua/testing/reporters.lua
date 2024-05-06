local config = require("testing/config")
local lib = require("testing/lib")
local c = lib.colors

local ERROR_CONTEXT_LINE_COUNT = 3

---@class Reporter
---@field on_pass fun(result: TestResult)
---@field on_fail fun(result: TestResult)
---@field on_end fun(results: TestResult[])

local printf = function(format, ...)
  local output = string.format(c.RESET .. format .. c.RESET, ...)
  if config.output_file then
    local file = io.open(config.output_file, "a")
    if not file then error("Failed to open output file: " .. config.output_file) end
    file:write(output .. "\n")
    file:close()
  end
  if not config.quiet then io.write(output) end
end

---@param file string
---@param line number
local get_error_context = function(file, line)
  local lines = vim.fn.readfile(file)
  local start_line = math.max(1, line - ERROR_CONTEXT_LINE_COUNT)
  local end_line = math.min(#lines, line + ERROR_CONTEXT_LINE_COUNT)

  local context_lines = {}
  for i = start_line, end_line do
    local is_error_line = i == line
    local line_number = (is_error_line and c.BRIGHT_RED or "") .. string.format("%3d", i)
    local line_content = (is_error_line and c.RED or "") .. lines[i]
    local prefix = i == line and ">" or "|"
    table.insert(context_lines, string.format(c.WHITE .. "%s %s %s" .. c.RESET, prefix, line_number, line_content))
  end

  return table.concat(context_lines, "\n")
end

local inspect = function(value)
  if type(value) == "string" then return value end
  return vim.inspect(value)
end

---@type Reporter
local default = {
  on_pass = function(result)
    printf(
      c.GREEN
        .. c.BOLD
        .. "PASS"
        .. c.RESET
        .. c.MAGENTA
        .. " %s"
        .. c.YELLOW
        .. " %s "
        .. c.BRIGHT_BLACK
        .. "(%dms)\n",
      result.file,
      result.name,
      result.duration
    )
  end,
  on_fail = function(result)
    printf(
      c.BRIGHT_RED
        .. c.BOLD
        .. "FAIL"
        .. c.RESET
        .. c.MAGENTA
        .. " %s:%d"
        .. c.YELLOW
        .. " %s "
        .. c.BRIGHT_BLACK
        .. "(%dms)\n",
      result.file,
      result.error.line,
      result.name,
      result.duration
    )
    printf(lib.text.format_indent(
      string.format(
        --
        c.RED
          .. "Error:"
          .. c.RESET
          .. " %s\n",
        result.error.message
      ),
      2
    ))
    printf(lib.text.format_indent(
      string.format(
        --
        c.CYAN
          .. "Expected: "
          .. c.GREEN
          .. "%s"
          .. c.CYAN
          .. "\nActual: "
          .. c.RED
          .. "%s\n",
        inspect(result.error.expected),
        inspect(result.error.actual)
      ),
      4
    ))
    printf(
      lib.text.format_indent(
        string.format("%s\n", get_error_context(lib.path.resolve(result.file), result.error.line)),
        2
      )
    )
  end,
  on_end = function(results)
    local failed_count = #vim.tbl_filter(function(result)
      return result.error
    end, results)
    local duration = 0
    for _, result in ipairs(results) do
      duration = duration + result.duration
    end
    printf(
      "Ran "
        .. c.CYAN
        .. "%d"
        .. c.RESET
        .. " tests in %dms. Passed: "
        .. c.GREEN
        .. "%d"
        .. c.RESET
        .. " Failed: "
        .. (failed_count > 0 and c.RED or c.GREEN)
        .. "%d\n",
      #results,
      duration,
      #results - failed_count,
      failed_count
    )
  end,
}

return {
  default = default,
}

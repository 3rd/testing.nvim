local config = require("testing/config")
local lib = require("testing/lib")
local c = lib.colors

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

local inspect = function(value)
  if type(value) == "string" then return value end
  return vim.inspect(value)
end

---@type Reporter
local default = {
  on_pass = function(result)
    printf(
      c.GREEN .. c.BOLD .. "PASS" .. c.RESET .. c.MAGENTA .. " %s" .. c.YELLOW .. " %s " .. c.BRIGHT_BLACK .. "(%dms)\n",
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
        "Expected: "
          .. c.GREEN
          .. "%s"
          .. c.RESET
          .. "\nActual: "
          .. c.RED
          .. "%s\n",
        inspect(result.error.expected),
        inspect(result.error.actual)
      ),
      4
    ))
  end,
  on_end = function(results)
    local failed_count = #vim.tbl_filter(function(result)
      return result.error
    end, results)
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
      results[1].duration,
      #results - failed_count,
      failed_count
    )
  end,
}

return {
  default = default,
}

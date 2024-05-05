local config = require("testing/config")
local lib = require("testing/lib")

---@class Reporter
---@field on_pass fun(result: TestResult)
---@field on_fail fun(result: TestResult)
---@field on_end fun(results: TestResult[])

local printf = function(format, ...)
  local output = string.format(format, ...)
  if config.output_file then
    local file = io.open(config.output_file, "a")
    if not file then error("Failed to open output file: " .. config.output_file) end
    file:write(output .. "\n")
    file:close()
  end
  if not config.quiet then print(output) end
end

local inspect = function(value)
  if type(value) == "string" then return value end
  return vim.inspect(value)
end

---@type Reporter
local default = {
  on_pass = function(result)
    printf("PASS %s %s (%dms)", result.file, result.name, result.duration)
  end,
  on_fail = function(result)
    printf("FAIL %s %s (%dms)", result.file, result.name, result.duration)
    printf(lib.text.format_indent(
      string.format(
        --
        "Error: %s",
        result.error.message
      ),
      2
    ))
    printf(lib.text.format_indent(
      string.format(
        --
        "Expected: %s\nActual: %s",
        inspect(result.error.expected),
        inspect(result.error.actual)
      ),
      4
    ))
  end,
  on_end = function(results)
    printf("Ran %d tests in %dms", #results, results[1].duration)
    printf("Passed: %d, Failed: %d", #results - #vim.tbl_filter(function(result)
      return result.passed
    end, results), #vim.tbl_filter(function(result)
      return not result.passed
    end, results))
  end,
}

return {
  default = default,
}

local lib = require("testing/lib")

---@alias AssertionError { message: string, expected: any, actual: any }

---@class Expect
---@field toBe fun(expected: any): nil
---@field toEqual fun(expected: any): nil
---@field toContain fun(expected: any): nil
---@field toMatch fun(expected: any): nil
---@field toThrow fun(expected: any): nil
---@field n Expect

local assertions = {
  toBe = function(actual, expected, is_negated)
    local is_equal = actual == expected
    if is_negated then
      if is_equal then
        return {
          message = "Expected values not to be equal",
          expected = string.format("Not %q", expected),
          actual = expected,
        }
      end
    else
      if not is_equal then
        return {
          message = "Expected values to be equal",
          expected = expected,
          actual = actual,
        }
      end
    end
  end,
  toEqual = function(actual, expected, is_negated)
    local is_deep_equal = vim.deep_equal(actual, expected)
    if is_negated then
      if is_deep_equal then
        return {
          message = "Expected values not to be deeply equal",
          expected = string.format("Not %q", expected),
          actual = expected,
        }
      end
    else
      if not is_deep_equal then
        return {
          message = "Expected values to be deeply equal",
          expected = expected,
          actual = actual,
        }
      end
    end
  end,
  toContain = function(haystack, needle, is_negated)
    if type(haystack) ~= "table" then error("Expected value to be a table") end
    local is_contained = vim.tbl_contains(haystack, needle)
    if is_negated then
      if is_contained then
        return {
          message = "Expected table not to contain value",
          expected = needle,
          actual = haystack,
        }
      end
    else
      if not is_contained then
        return {
          message = "Expected table to contain value",
          expected = needle,
          actual = haystack,
        }
      end
    end
  end,
  toMatch = function(haystack, needle, is_negated)
    if type(needle) ~= "string" or type(haystack) ~= "string" then error("Expected values to be strings") end
    local is_matched = string.find(haystack, needle)
    if is_negated then
      if is_matched then
        return {
          message = "Expected string not to match pattern",
          expected = needle,
          actual = haystack,
        }
      end
    else
      if not is_matched then
        return {
          message = "Expected string to match pattern",
          expected = needle,
          actual = haystack,
        }
      end
    end
  end,
  toThrow = function(fn, error_needle, is_negated)
    local ok, err = pcall(fn)
    if is_negated then
      if error_needle == nil then
        if not ok then
          return {
            message = "Expected function to throw an error",
            expected = error_needle,
            actual = err,
          }
        end
      else
        if string.find(err, error_needle) then
          return {
            message = "Expected function not to throw a matching error",
            expected = error_needle,
            actual = err,
          }
        end
      end
    else
      if ok then
        return {
          message = "Expected function to throw an error",
          expected = error_needle,
          actual = err,
        }
      end
      if error_needle ~= nil and not string.find(err, error_needle) then
        return {
          message = "Expected function not to throw a matching error",
          expected = error_needle,
          actual = err,
        }
      end
    end
  end,
}

---@param state State
local create_expect = function(state)
  return function(actual)
    if not state.current_test then error("You must call it() before expect()") end

    local handle_error = function(error_message, assert_expected, assert_actual)
      local stacktrace = lib.stacktrace.get_stack_trace(2)
      state.current_test.error = {
        message = error_message,
        file = stacktrace.path,
        line = stacktrace.line,
        actual = assert_actual,
        expected = assert_expected,
      }
    end

    ---@type Expect
    ---@diagnostic disable-next-line: missing-fields
    local expect_return = { n = {} }
    for k, v in pairs(assertions) do
      ---@diagnostic disable-next-line: assign-type-mismatch
      expect_return[k] = function(...)
        if state.current_test.error then return end
        local error = v(actual, ..., false)
        if error then handle_error(error.message, error.expected, error.actual) end
      end
      expect_return.n[k] = function(...)
        if state.current_test.error then return end
        local error = v(actual, ..., true)
        if error then handle_error(error.message, error.expected, error.actual) end
      end
    end

    return expect_return
  end
end

return {
  create_expect = create_expect,
}

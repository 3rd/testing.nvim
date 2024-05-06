local lib = require("testing/lib")

---@alias AssertionError { message: string, expected: any, actual: any }

---@class Expect
---@field toBe fun(expected: any): nil
---@field toEqual fun(expected: any): nil
---@field toContain fun(expected: any): nil
---@field toMatch fun(expected: string, is_regex?: boolean): nil
---@field toThrow fun(expected?: string, is_regex?: boolean): nil
---@field toHaveBeenCalled fun(): nil
---@field toHaveBeenCalledTimes fun(n: number): nil
---@field toHaveBeenCalledWith fun(...): nil
---@field toHaveBeenLastCalledWith fun(...): nil
---@field toHaveBeenNthCalledWith fun(n: number, ...): nil
---@field n Expect

local assertions = {
  toBe = function(is_negated, actual, expected)
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
  toEqual = function(is_negated, actual, expected)
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
  toContain = function(is_negated, haystack, needle)
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
  toMatch = function(is_negated, haystack, needle, is_regex)
    if type(needle) ~= "string" or type(haystack) ~= "string" then error("Expected values to be strings") end
    local is_matched = string.find(haystack, needle, nil, not is_regex)
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
  toThrow = function(is_negated, fn, error_needle, is_regex)
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
      if error_needle ~= nil and not string.find(err, error_needle, nil, not is_regex) then
        return {
          message = "Expected function to throw a matching error",
          expected = error_needle,
          actual = err,
        }
      end
    end
  end,
  toHaveBeenCalled = function(is_negated, spy)
    if is_negated then
      if spy.calls[1] then
        return {
          message = "Expected spy not to have been called",
          expected = "0 calls",
          actual = string.format("%d calls", #spy.calls),
        }
      end
    else
      if not spy.calls[1] then
        return {
          message = "Expected spy to have been called",
          expected = "> 0 calls",
          actual = "0 calls",
        }
      end
    end
  end,
  toHaveBeenCalledTimes = function(is_negated, spy, n)
    if is_negated then
      if #spy.calls == n then
        return {
          message = "Expected spy not to have been called",
          expected = string.format("not %d calls", n),
          actual = string.format("%d calls", #spy.calls),
        }
      end
    else
      if #spy.calls ~= n then
        return {
          message = "Expected spy to have been called",
          expected = string.format("%d calls", n),
          actual = string.format("%d calls", #spy.calls),
        }
      end
    end
  end,
  toHaveBeenCalledWith = function(is_negated, spy, ...)
    local args = { ... }
    local found = false
    for _, call in ipairs(spy.calls) do
      if vim.deep_equal(call.args, args) then
        found = true
        break
      end
    end
    if is_negated then
      if found then
        return {
          message = "Expected spy not to have been called with args",
          expected = args,
          actual = spy.calls,
        }
      end
    else
      if not found then
        return {
          message = "Expected spy to have been called with args",
          expected = args,
          actual = spy.calls,
        }
      end
    end
  end,
  toHaveBeenLastCalledWith = function(is_negated, spy, ...)
    local args = { ... }
    if #spy.calls == 0 then
      return {
        message = "Expected spy to have been called",
        expected = "> 0 calls",
        actual = "0 calls",
      }
    end
    local last_call = spy.calls[#spy.calls]
    if is_negated then
      if vim.deep_equal(last_call.args, args) then
        return {
          message = "Expected spy not to have been last called with args",
          expected = args,
          actual = last_call.args,
        }
      end
    else
      if not vim.deep_equal(last_call.args, args) then
        return {
          message = "Expected spy to have been last called with args",
          expected = args,
          actual = last_call.args,
        }
      end
    end
  end,
  toHaveBeenNthCalledWith = function(is_negated, spy, n, ...)
    local args = { ... }
    if #spy.calls < n then
      return {
        message = string.format("Expected spy to have been called at least %d times", n),
        expected = string.format(">= %d calls", n),
        actual = string.format("%d calls", #spy.calls),
      }
    end
    local nth_call = spy.calls[n]
    if is_negated then
      if vim.deep_equal(nth_call.args, args) then
        return {
          message = string.format("Expected spy not to have been called %dth time with args", n),
          expected = args,
          actual = nth_call.args,
        }
      end
    else
      if not vim.deep_equal(nth_call.args, args) then
        return {
          message = string.format("Expected spy to have been called %dth time with args", n),
          expected = args,
          actual = nth_call.args,
        }
      end
    end
  end,
}

---@param state State
local create_expect = function(state)
  return function(actual)
    if not state.current_test then error("You must call it() before expect()") end

    local handle_error = function(error_message, assert_actual, assert_expected)
      local stacktrace = lib.stacktrace.get_stack_trace(2)
      local escaped_error = error_message:gsub("%%", "%%%%")
      local escaped_actual = type(assert_actual) == "string" and assert_actual:gsub("%%", "%%%%") or assert_actual
      local escaped_expected = type(assert_expected) == "string" and assert_expected:gsub("%%", "%%%%")
        or assert_expected
      state.current_test.error = {
        message = escaped_error,
        file = stacktrace.path,
        line = stacktrace.line,
        actual = escaped_actual,
        expected = escaped_expected,
      }
    end

    ---@type Expect
    ---@diagnostic disable-next-line: missing-fields
    local expect_return = { n = {} }
    for k, v in pairs(assertions) do
      ---@diagnostic disable-next-line: assign-type-mismatch
      expect_return[k] = function(...)
        if state.current_test.error then return end
        local error = v(false, actual, ...)
        if error then handle_error(error.message, error.actual, error.expected) end
      end
      expect_return.n[k] = function(...)
        if state.current_test.error then return end
        local error = v(true, actual, ...)
        if error then handle_error(error.message, error.actual, error.expected) end
      end
    end

    return expect_return
  end
end

return {
  create_expect = create_expect,
}

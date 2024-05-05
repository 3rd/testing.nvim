local create_describe = require("testing/core/describe").create_describe
local create_it = require("testing/core/it").create_it
local create_expect = require("testing/core/expect").create_expect

---@class TestError
---@field message string
---@field file string
---@field line number | nil
---@field actual any
---@field expected any

---@class TestResult
---@field file string
---@field name string
---@field error TestError | nil
---@field duration number
---@field stacktrace StackTrace

---@class State
---@field current_suite { suite_name: string, file: string } | nil
---@field current_test { test_name: string, error: TestError | nil } | nil
---@field results TestResult[]

---@class State
local state = {
  current_suite = nil,
  current_test = nil,
  results = {},
}

return {
  describe = create_describe(state),
  it = create_it(state),
  expect = create_expect(state),
}

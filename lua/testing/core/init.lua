local create_describe = require("testing/core/describe").create_describe
local create_it = require("testing/core/it").create_it
local create_expect = require("testing/core/expect").create_expect
local create_spy = require("testing/core/spy").create_spy

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
---@field spies { [function]: boolean|nil }

---@class State
local state = {
  current_suite = nil,
  current_test = nil,
  results = {},
  spies = {},
}

return {
  state = state,
  describe = create_describe(state),
  it = create_it(state),
  expect = create_expect(state),
  spy = create_spy(state),
}

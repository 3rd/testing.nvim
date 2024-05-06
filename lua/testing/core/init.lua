local create_describe = require("testing/core/describe").create_describe
local create_it = require("testing/core/it").create_it
local create_expect = require("testing/core/expect").create_expect
local create_spy = require("testing/core/spy").create_spy
local create_hooks = require("testing/core/hooks").create_hooks

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

---@class Suite
---@field suite_name string
---@field file string
---@field hooks { before_each: function[], after_each: function[] }

---@class State
---@field current_suite Suite | nil
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
  hooks = create_hooks(state),
}

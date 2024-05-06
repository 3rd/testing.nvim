local config = require("testing/config")
local lib = require("testing/lib")

---@param state State
local create_it = function(state)
  return function(test_name, fn)
    if state.current_suite == nil then error("You must call describe() before it()") end
    if state.current_test ~= nil then error("You cannot have it() inside another it()") end

    local stacktrace = lib.stacktrace.get_stack_trace(1)
    state.current_test = { test_name = test_name }

    for _, before_each_fn in ipairs(state.current_suite.hooks.before_each) do
      before_each_fn()
    end

    local startTime = vim.loop.hrtime()
    fn()
    local duration_ms = (vim.loop.hrtime() - startTime) / 1000000

    for _, after_each_fn in ipairs(state.current_suite.hooks.after_each) do
      after_each_fn()
    end

    ---@type TestResult
    local test_result = {
      file = state.current_suite.file,
      name = string.format("%s / %s", state.current_suite.suite_name, test_name):gsub("%%", "%%%%"),
      error = state.current_test.error,
      duration = duration_ms,
      stacktrace = stacktrace,
    }

    if test_result.error then
      if config.exit_on_first_fail then
        config.reporter.on_fail(test_result)
        config.reporter.on_end(state.results)
        os.exit(1)
      end
    end

    table.insert(state.results, test_result)

    if test_result.error then
      config.reporter.on_fail(test_result)
    else
      config.reporter.on_pass(test_result)
    end

    state.current_test = nil
  end
end

return {
  create_it = create_it,
}

local lib = require("testing/lib")

---@param state State
local create_describe = function(state)
  return function(suite_name, fn)
    if state.current_suite ~= nil then error("You cannot have describe() inside another describe()") end

    local stacktrace = lib.stacktrace.get_stack_trace(1)
    state.current_suite = { suite_name = suite_name, file = stacktrace.path }

    fn()

    state.current_suite = nil

    -- for _, result in ipairs(state.results) do
    --   if not result.passed then os.exit(1) end
    -- end
  end
end

return {
  create_describe = create_describe,
}

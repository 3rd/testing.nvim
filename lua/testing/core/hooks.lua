---@param state State
local create_hooks = function(state)
  ---@param fn function
  local before_each = function(fn)
    if state.current_suite == nil then error("Hooks can only be set up inside describe() blocks") end
    table.insert(state.current_suite.hooks.before_each, fn)
  end

  ---@param fn function
  local after_each = function(fn)
    if state.current_suite == nil then error("Hooks can only be set up inside describe() blocks") end
    table.insert(state.current_suite.hooks.after_each, fn)
  end

  return { before_each = before_each, after_each = after_each }
end

return {
  create_hooks = create_hooks,
}

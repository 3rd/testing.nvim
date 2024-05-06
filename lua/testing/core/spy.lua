---@class Spy
---@field target table
---@field key string
---@field original function
---@field spy_func function
---@field mock_func function|nil
---@field calls { args: any[], result: any }[]
---@field reset fun()
---@field clear fun()
---@field destroy fun()
---@field mockImplementation fun(fn: function)
---@field mockImplementationOnce fun(fn: function)
---@field mockReturnValue fun(value: any)
---@field mockReturnValueOnce fun(value: any)
---@field mockRestore fun()

---@param state State
---@param target table
---@param key string
---@return Spy
local create_spy_object = function(state, target, key)
  local self = {
    target = target,
    key = key,
    original = target[key],
    mock_func = nil,
    calls = {},
  }

  self.reset = function()
    self.mock_func = nil
    self.calls = {}
  end

  self.clear = function()
    self.calls = {}
  end

  self.destroy = function()
    state.spies[self.spy_func] = nil
    self.spy_func = nil
    self.target[self.key] = self.original
  end

  ---@param fn function
  self.mockImplementation = function(fn)
    if not self.spy_func then error("Spy has been destroyed") end
    self.mock_func = function(...)
      return fn(...)
    end
  end

  ---@param fn function
  self.mockImplementationOnce = function(fn)
    if not self.spy_func then error("Spy has been destroyed") end
    self.mock_func = function(...)
      self.mock_func = nil
      return fn(...)
    end
  end

  ---@param value any
  self.mockReturnValue = function(value)
    if not self.spy_func then error("Spy has been destroyed") end
    self.mock_func = function()
      return value
    end
  end

  ---@param value any
  self.mockReturnValueOnce = function(value)
    if not self.spy_func then error("Spy has been destroyed") end
    self.mock_func = function()
      self.mock_func = nil
      return value
    end
  end

  return self
end

---@param state State
local create_spy = function(state)
  ---@param target table
  ---@param key string
  ---@return Spy
  return function(target, key)
    if type(target) ~= "table" then error("Cannot spy on a non-table value") end

    local original = target[key]
    if type(original) ~= "function" then error("Can only spy on functions") end

    if state.spies[original] ~= nil then error("Cannot spy on a spy") end

    ---@type Spy
    local s = create_spy_object(state, target, key)
    s.spy_func = function(...)
      local result = s.mock_func and s.mock_func(...) or original(...)
      table.insert(s.calls, { args = { ... }, result = result })
      return result
    end
    s.target[s.key] = s.spy_func

    state.spies[s.spy_func] = true
    return s
  end
end

return {
  create_spy = create_spy,
}

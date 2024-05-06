local t = require("testing")

describe("mocks", function()
  it("spies on function calls", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")

    expect(spy).n.toHaveBeenCalled()
    expect(spy).toHaveBeenCalledTimes(0)

    obj.foo(1, 2)
    expect(spy).toHaveBeenCalled()
    expect(spy).toHaveBeenCalledTimes(1)
    expect(spy).n.toHaveBeenCalledTimes(2)
    expect(spy).toHaveBeenCalledWith(1, 2)
    expect(spy).n.toHaveBeenCalledWith(0)
    expect(spy).toHaveBeenLastCalledWith(1, 2)
    expect(spy).n.toHaveBeenLastCalledWith(0)
    expect(spy).toHaveBeenNthCalledWith(1, 1, 2)
    expect(spy).n.toHaveBeenNthCalledWith(1, 0)

    obj.foo(3, 4)

    expect(spy).toHaveBeenCalledTimes(2)
    expect(spy).toHaveBeenCalledWith(3, 4)
    expect(spy).toHaveBeenLastCalledWith(3, 4)
    expect(spy).toHaveBeenNthCalledWith(1, 1, 2)
    expect(spy).toHaveBeenNthCalledWith(2, 3, 4)
  end)

  it("destroys a spy", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")

    obj.foo(1, 2)
    spy.destroy()
    obj.foo(3, 4)

    expect(spy).toHaveBeenCalledTimes(1)
    expect(spy).toHaveBeenCalledWith(1, 2)
  end)

  it("clears calls on a spy", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    obj.foo(1, 2)

    expect(spy).toHaveBeenCalledTimes(1)
    spy.clear()
    expect(spy).toHaveBeenCalledTimes(0)
  end)

  it("mocks implementation", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockImplementation(function()
      return 42
    end)

    expect(obj.foo(2, 3)).toBe(42)
    expect(obj.foo(2, 3)).toBe(42)
  end)

  it("mocks implementation once", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockImplementationOnce(function()
      return 42
    end)

    expect(obj.foo(2, 3)).toBe(42)
    expect(obj.foo(2, 3)).toBe(5)
  end)

  it("resets after a mocked implementation", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockImplementation(function()
      return 42
    end)

    expect(obj.foo(2, 3)).toBe(42)
    spy.reset()
    expect(obj.foo(2, 3)).toBe(5)
  end)

  it("mocks return value", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockReturnValue(42)

    expect(obj.foo(2, 3)).toBe(42)
    expect(obj.foo(4, 5)).toBe(42)
  end)

  it("mocks return value once", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockReturnValueOnce(42)

    expect(obj.foo(2, 3)).toBe(42)
    expect(obj.foo(2, 3)).toBe(5)
  end)

  it("resets after a mocked return value", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    local spy = t.spy(obj, "foo")
    spy.mockImplementation(function()
      return 42
    end)

    expect(obj.foo(2, 3)).toBe(42)
    spy.reset()
    expect(obj.foo(2, 3)).toBe(5)
  end)

  it("throws when spying on a non-table target", function()
    expect(function()
      ---@diagnostic disable-next-line: param-type-mismatch
      t.spy(42, "foo")
    end).toThrow("Cannot spy on a non-table value")
  end)

  it("throws when spying on a non-function", function()
    expect(function()
      t.spy({}, "foo")
    end).toThrow("Can only spy on functions")
  end)

  it("throws when spying on a spy", function()
    local obj = {
      foo = function(a, b)
        return a + b
      end,
    }
    t.spy(obj, "foo")

    expect(function()
      t.spy(obj, "foo")
    end).toThrow("Cannot spy on a spy")
  end)
end)

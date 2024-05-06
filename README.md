# testing.nvim

**testing.nvim** is a minimal testing solution for Neovim plugins.

### Setup

**Non-interactive setup**

To set this up for non-interactive testing with Neovim (`:help -l`):

1. Create a lua file that bootstraps your testing context by:
   - Adding your plugin and `testing.nvim` to the `rtp`
   - Calling `require("testing").setup(...)`
2. Launch Neovim with the bootstrap file loaded as a session script and the test file.
   - `nvim -S ./bootstrap.lua -l ./lua/your_spec.lua`

### Configuration

Configuration schema and default values:

```lua
---@class UserConfig
---@field exit_on_first_fail? boolean
---@field file_patterns? table<string>
---@field inject_globals? boolean
---@field output_file? string|nil
---@field quiet? boolean
---@field reporter? Reporter

local default_config = {
  exit_on_first_fail = false,
  file_patterns = { "**/*_spec.lua" },
  inject_globals = true,
  output_file = nil,
  quiet = false,
}
```

### Usage

This is what the plugin exports:

- `setup(config?)` - setup function, needs to be called to set globals
- `describe("...", fn)` - declare a test group / suite
- `it("...", fn)` - declare a test inside a test group
- `expect(actual).toSomething(...)` - make an assertion
- `spy(target, "key")` - spy & mock functions

Check out these files for the implementation:

- [testing/core/describe.lua](lua/testing/core/describe.lua)
- [testing/core/it.lua](lua/testing/core/it.lua)
- [testing/core/expect.lua](lua/testing/core/expect.lua)

**Assertions**

- `expect(actual).toBe(expected)` - `actual == expected`
- `expect(actual).toEqual(expected)` - `vim.deep_equal(actual, expected)`
- `expect(actual).toContain(expected)` - `vim.tbl_contains(actual, expected)`
- `expect(actual).toMatch(pattern)` - `string.find(actual, expected)`
- `expect(actual).toThrow(message?)`- expect `actual()` to throw (w/ optional error)
- `expect(spy).toHaveBeenCalled()`
- `expect(spy).toHaveBeenCalledTimes(n)`
- `expect(spy).toHaveBeenCalledWith(...)`
- `expect(spy).toHaveBeenLastCalledWith(...)`
- `expect(spy).toHaveBeenNthCalledWith(n, ...)`

**Negated assertions**

All the assertions have negated variants under `expect(actual).n`:

- `expect(actual).n.toBe(expected)`
- ...

**Examples**

```lua
describe("expect", function()
  it("asserts .toEqual(value)", function()
    expect(1).toEqual(1)
    expect(vim).toEqual(vim)
    expect({}).toEqual({})
    expect({ a = 1 }).toEqual({ a = 1 })
  end)

  it("asserts .n.toEqual(value)", function()
    expect(1).n.toEqual(2)
    expect(vim).n.toEqual(vim.api)
    expect({}).n.toEqual({ 1 })
    expect({ a = 1 }).n.toEqual({ a = 2 })
  end)
end)
```

**Spies/mocks**

To spy & mock a function, use the exported `.spy(target, "key")` helper.
\
It returns a `Spy` object on which you can call:

- `spy.clear()` - to clear the stored calls from memory
- `spy.reset()` - to clear the mocked implementation / return value and internal state
- `spy.destroy()` - to kill the spy and restore the original function
- `spy.mockImplementation(fn)`
- `spy.mockImplementationOnce(fn)`
- `spy.mockReturnValue(value)`
- `spy.mockReturnValueOnce(value)`

```lua
local t = require("testing")

describe("milkshake", function()
  it("brings all the boys to the yard", function()
    local target = {
      bring_boys = function()
        return false
      end,
    }
    local spy = t.spy(target, "bring_boys")

    expect(target.bring_boys()).toBe(false)
    expect(spy).toHaveBeenCalled()

    spy.mockReturnValueOnce(true)
    expect(target.bring_boys()).toBe(true)
    expect(target.bring_boys()).toBe(false)

    expect(spy).toHaveBeenCalledTimes(3)
  end)
end)
```

### WIP

- test runner
- child process wrapping (rpc)
- GH action

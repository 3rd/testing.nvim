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

This is what the plugin exports at its root:

- `setup(config?)` - setup function, needs to be called to set globals
- `describe("...", fn)` - declare a test group / suite
- `it("...", fn)` - declare a test inside a test group
- `expect(actual).toSomething(...)` - make an assertion

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

### WIP

- test runner, exit codes
- spies & mocks
- child process wrapping (rpc)
- GH action

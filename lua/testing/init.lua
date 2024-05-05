local config = require("testing/config")
local core = require("testing/core")
local reporters = require("testing/reporters")

---@param user_config? UserConfig
local setup = function(user_config)
  config:set(vim.tbl_deep_extend("force", { reporter = reporters.default }, user_config or {}))
  if config.inject_globals then
    _G.describe = core.describe
    _G.expect = core.expect
    _G.it = core.it
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      local failed_count = #vim.tbl_filter(function(result)
        return result.error
      end, core.state.results)

      config.reporter.on_end(core.state.results)
      if failed_count > 0 then os.exit(1) end
    end,
  })
end

return {
  describe = core.describe,
  expect = core.expect,
  it = core.it,
  setup = setup,
}

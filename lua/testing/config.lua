---@class UserConfig
---@field exit_on_first_fail? boolean
---@field file_patterns? table<string>
---@field inject_globals? boolean
---@field output_file? string|nil
---@field quiet? boolean
---@field reporter? Reporter

---@class Config
---@field exit_on_first_fail boolean
---@field file_patterns table<string>
---@field inject_globals boolean
---@field output_file string|nil
---@field quiet boolean
---@field reporter Reporter
---@field set fun(self: Config, user_config?: UserConfig)

---@class Config
local config = {
  exit_on_first_fail = false,
  file_patterns = { "**/*_spec.lua" },
  inject_globals = true,
  output_file = nil,
  quiet = false,
}

---@param user_config? UserConfig
local set = function(_, user_config)
  for k, v in pairs(user_config or {}) do
    config[k] = v
  end
end

local metatable = {
  __index = {
    set = set,
  },
}
setmetatable(config, metatable)

return config

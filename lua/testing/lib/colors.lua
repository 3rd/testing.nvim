---@class colors
local colors = {
  -- mods
  RESET = "[0m",
  BOLD = "[1m",
  ITALIC = "[3m",
  UNDERLINE = "[4m",
  -- colors
  BLACK = "[30m",
  RED = "[31m",
  GREEN = "[32m",
  YELLOW = "[33m",
  BLUE = "[34m",
  MAGENTA = "[35m",
  CYAN = "[36m",
  WHITE = "[37m",
  -- bright colors
  BRIGHT_BLACK = "[90m",
  BRIGHT_RED = "[91m",
  BRIGHT_GREEN = "[92m",
  BRIGHT_YELLOW = "[93m",
  BRIGHT_BLUE = "[94m",
  BRIGHT_MAGENTA = "[95m",
  BRIGHT_CYAN = "[96m",
  BRIGHT_WHITE = "[97m",
  -- background colors
  BG_BLACK = "[40m",
  BG_RED = "[41m",
  BG_GREEN = "[42m",
  BG_YELLOW = "[43m",
  BG_BLUE = "[44m",
  BG_MAGENTA = "[45m",
  BG_CYAN = "[46m",
  BG_WHITE = "[47m",
  -- bright background colors
  BG_BRIGHT_BLACK = "[100m",
  BG_BRIGHT_RED = "[101m",
  BG_BRIGHT_GREEN = "[102m",
  BG_BRIGHT_YELLOW = "[103m",
  BG_BRIGHT_BLUE = "[104m",
  BG_BRIGHT_MAGENTA = "[105m",
  BG_BRIGHT_CYAN = "[106m",
  BG_BRIGHT_WHITE = "[107m",
}

---@return colors
local build_colors = function()
  local with_colors = os.getenv("TERM") and not os.getenv("NO_COLOR")

  if not with_colors then return vim.tbl_map(function()
    return ""
  end, colors) end

  return vim.tbl_map(function(color)
    return string.char(27) .. color
  end, colors)
end

return build_colors()

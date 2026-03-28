local M = {}

---@class CcuiConfig
---@field input CcuiConfig.Input
---@field chat CcuiConfig.Chat

---@class CcuiConfig.Input
---@field height number
---@field placeholder string
---@field winbar CcuiConfig.WinbarItem[]|{ enabled: boolean }

---@alias CcuiConfig.WinbarItem string|CcuiConfig.WinbarComponent

---@class CcuiConfig.WinbarComponent
---@field component? string|fun(chat: CodeCompanion.Chat): string|nil
---@field hl? string
---@field fg? string
---@field bg? string
---@field [string] any Component-specific options (e.g. icons, frames)

---@class CcuiConfig.Chat
---@field width number

local defaults = {
  input = {
    height = 10,
    -- Placeholder shown when the input buffer is empty
    placeholder = 'Type your message...',
    winbar = {
      {
        component = 'mode',
        display_names = {},
        icons = {
          default = '',
          acceptEdits = '󱐋',
          plan = '󰙬',
          dontAsk = '󱐋',
          bypassPermissions = '󰒃',
        },
      },
      { component = 'adapter' },
      { component = 'model' },
      {
        component = 'spinner',
        interval_ms = 100,
        frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        text = 'Processing...',
      },
      '%=',
      { component = 'messages' },
    },
  },
  chat = {
    -- Chat window width as a fraction of the screen (0.0–1.0)
    width = 0.35,
  },
}

---@type CcuiConfig
M.config = vim.deepcopy(defaults)

---@param name string
---@return CcuiConfig.WinbarComponent?
function M.get_component(name)
  if not M.config.input or not M.config.input.winbar then
    return nil
  end
  for _, item in ipairs(M.config.input.winbar) do
    if type(item) == 'table' and item.component == name then
      return item
    end
  end
  return nil
end

---@param opts? CcuiConfig
function M.setup(opts)
  -- Winbar is a list — replace wholesale rather than deep-merging by index
  local user_winbar = opts and opts.input and opts.input.winbar
  if opts and opts.input then
    opts.input.winbar = nil
  end
  M.config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
  if user_winbar then
    M.config.input.winbar = user_winbar
  end

  -- Validate critical config values
  if M.config.input.height <= 0 then
    vim.notify('codecompanion-ui: input.height must be positive, using default', vim.log.levels.WARN)
    M.config.input.height = defaults.input.height
  end

  if M.config.chat.width < 0.0 or M.config.chat.width > 1.0 then
    vim.notify('codecompanion-ui: chat.width must be between 0.0 and 1.0, using default', vim.log.levels.WARN)
    M.config.chat.width = defaults.chat.width
  end

  local spinner = M.get_component('spinner')
  if spinner then
    if spinner.interval_ms and spinner.interval_ms <= 0 then
      vim.notify('codecompanion-ui: spinner.interval_ms must be positive, using default', vim.log.levels.WARN)
      spinner.interval_ms = 100
    end
    if not spinner.frames or #spinner.frames == 0 then
      vim.notify('codecompanion-ui: spinner.frames must be non-empty, using default', vim.log.levels.WARN)
      spinner.frames = defaults.input.winbar[4].frames
    end
  end
end

---@type CcuiConfig|{setup: fun(opts?: CcuiConfig), config: CcuiConfig, get_component: fun(name: string): CcuiConfig.WinbarComponent?}
return setmetatable(M, {
  __index = function(_, key)
    if key == 'setup' then
      return M.setup
    end
    if key == 'get_component' then
      return M.get_component
    end
    return rawget(M.config, key)
  end,
})

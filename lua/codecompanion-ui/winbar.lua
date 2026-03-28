local M = {}

local components = require('codecompanion-ui.components')

local hl_cache = {}
local hl_counter = 0

---@param fg? string
---@param bg? string
---@return string
local function get_dynamic_hl(fg, bg)
  local key = (fg or '') .. ':' .. (bg or '')
  if hl_cache[key] then
    return hl_cache[key]
  end
  hl_counter = hl_counter + 1
  local name = 'CcuiDyn_' .. tostring(hl_counter)
  local def = {}
  if fg then
    def.fg = fg
  end
  if bg then
    def.bg = bg
  end
  vim.api.nvim_set_hl(0, name, def)
  hl_cache[key] = name
  return name
end

---@param text string
---@param hl string
---@return string
local function wrap_hl(text, hl)
  return string.format('%%#%s# %s ', hl, text)
end

---@param text string
---@param item CcuiConfig.WinbarComponent
---@return string
local function apply_style(text, item)
  if item.hl then
    return wrap_hl(text, item.hl)
  elseif item.fg or item.bg then
    return wrap_hl(text, get_dynamic_hl(item.fg, item.bg))
  end
  return ''
end

-- Default styling for built-in components. Applied when the user
-- does not provide hl/fg/bg overrides on the item.
---@type table<string, fun(text: string, session: CcuiSession): string>
local default_style = {
  mode = function(text)
    return string.format('%%#CcuiModeSep#%%#CcuiMode# %s %%#CcuiModeSep#', text)
  end,
  adapter = function(text)
    return string.format('%%#CcuiAdapter#  %s %%#CcuiAdapterSep#', text)
  end,
  model = function(text)
    return string.format('%%#CcuiModel# 󰧑 %s ', text)
  end,
  spinner = function(text)
    return string.format('%%#CcuiSpinner# %s ', text)
  end,
  messages = function(text, session)
    local hl = (session.message and session.message.hl) or 'WarningMsg'
    return string.format('%%#%s# %s ', hl, text)
  end,
}

---@return string
function M.eval_input()
  local State = require('codecompanion-ui.state')
  local config = require('codecompanion-ui.config')

  local session = State.active()
  if not session then
    return ''
  end

  local winbar = config.input.winbar
  if not winbar or #winbar == 0 then
    return ''
  end

  local ok, cc = pcall(require, 'codecompanion')
  if not ok then
    return ''
  end

  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return ''
  end

  local parts = {}

  for _, item in ipairs(winbar) do
    if type(item) == 'string' then
      table.insert(parts, item)
    elseif type(item) == 'table' and item.component then
      local has_style = item.hl or item.fg or item.bg
      local result

      if type(item.component) == 'string' then
        local comp = components[item.component]
        if comp then
          result = comp(chat, session, item)
        end
      elseif type(item.component) == 'function' then
        local fn_ok, fn_result = pcall(item.component, chat)
        if fn_ok then
          result = fn_result
        end
      end

      if result and result ~= '' then
        if has_style then
          table.insert(parts, apply_style(result, item))
        elseif type(item.component) == 'string' and default_style[item.component] then
          table.insert(parts, default_style[item.component](result, session))
        elseif type(item.component) == 'function' then
          table.insert(parts, apply_style(result, { hl = 'CcuiCustom' }))
        else
          table.insert(parts, result)
        end
      end
    end
  end

  return table.concat(parts)
end

---@param winid number
function M.set_input_winbar(winid)
  local config = require('codecompanion-ui.config')
  if not vim.api.nvim_win_is_valid(winid) then
    return
  end
  if not config.input.winbar or #config.input.winbar == 0 then
    return
  end
  vim.wo[winid].winbar = "%{%v:lua.require('codecompanion-ui.winbar').eval_input()%}"
end

return M

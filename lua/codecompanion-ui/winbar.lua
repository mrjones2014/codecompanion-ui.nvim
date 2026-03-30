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

---@param winbar_items CcuiConfig.WinbarItem[]
---@return string
local function eval(winbar_items)
  local State = require('codecompanion-ui.state')

  local session = State.active()
  if not session then
    return ''
  end

  if not winbar_items or #winbar_items == 0 then
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

  for _, item in ipairs(winbar_items) do
    if type(item) == 'string' then
      table.insert(parts, item)
    elseif type(item) == 'table' and item.component then
      local user_style = item.hl or item.fg or item.bg
      local result

      if type(item.component) == 'string' then
        local comp = components[item.component]
        if comp then
          result = comp(chat, session, item)
        end
      elseif type(item.component) == 'function' then
        local fn_ok, fn_result = pcall(item.component --[[@as fun(CodeCompanion.Chat): string]], chat)
        if fn_ok then
          result = fn_result
        end
      end

      if result and result ~= '' then
        local text, style
        if type(result) == 'table' then
          text = result.text
          -- User config overrides component defaults
          style = {
            hl = user_style and item.hl or result.hl,
            fg = user_style and item.fg or result.fg,
            bg = user_style and item.bg or result.bg,
          }
        else
          text = result
          style = user_style and item or { hl = 'CcuiCustom' }
        end

        if text and text ~= '' then
          table.insert(parts, apply_style(text, style))
        end
      end
    end
  end

  return table.concat(parts)
end

---@return string
function M.eval_input()
  local config = require('codecompanion-ui.config')
  return eval(config.input.winbar)
end

---@return string
function M.eval_chat()
  local config = require('codecompanion-ui.config')
  return eval(config.chat.winbar)
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

---@param winid number
function M.set_chat_winbar(winid)
  local config = require('codecompanion-ui.config')
  if not vim.api.nvim_win_is_valid(winid) then
    return
  end
  if not config.chat.winbar or #config.chat.winbar == 0 then
    return
  end
  vim.wo[winid].winbar = "%{%v:lua.require('codecompanion-ui.winbar').eval_chat()%}"
end

return M

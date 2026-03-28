local M = {}

---@class CcuiComponentOpts.Mode
---@field display_names? table<string, string> Rename modes for display
---@field icons? table<string, string> Icons per mode id

---@param chat CodeCompanion.Chat
---@param _ CcuiSession
---@param opts CcuiComponentOpts.Mode
---@return string
function M.mode(chat, _, opts)
  local mode_name = 'Plan Mode'
  local mode_id = 'plan'
  if chat.acp_connection and chat.acp_connection._modes then
    local modes = chat.acp_connection._modes
    local current_id = modes and modes.currentModeId or ''
    local mode_info = vim.iter(modes and modes.availableModes or {}):find(function(m)
      return m.id == current_id
    end)
    if mode_info then
      mode_name = mode_info.name
      mode_id = mode_info.id
    end
  end

  local display_names = opts.display_names or {}
  if display_names[mode_name] then
    mode_name = display_names[mode_name]
  end

  local icons = opts.icons or {}
  local icon = icons[mode_id] or ''

  return icon .. ' ' .. mode_name
end

---@param chat CodeCompanion.Chat
---@param _ CcuiSession
---@param _ CcuiConfig.WinbarComponent
---@return string
function M.adapter(chat, _, _)
  if chat.adapter then
    return chat.adapter.formatted_name or chat.adapter.name or ''
  end
  return ''
end

---@param chat CodeCompanion.Chat
---@param _ CcuiSession
---@param _ CcuiConfig.WinbarComponent
---@return string
function M.model(chat, _, _)
  -- ACP adapter
  if chat.acp_connection and chat.acp_connection._models then
    local models = chat.acp_connection._models
    local current_id = models and models.currentModelId or ''
    for _, model in ipairs(models and models.availableModels or {}) do
      if model.modelId == current_id then
        return model.name
      end
    end
  end

  -- HTTP adapter
  if chat.adapter and chat.adapter.model then
    local name = chat.adapter.model.name
    local choices = chat.adapter.schema and chat.adapter.schema.model and chat.adapter.schema.model.choices
    if choices and choices[name] and choices[name].formatted_name then
      return choices[name].formatted_name
    end
    return name or ''
  end

  return ''
end

---@class CcuiComponentOpts.Spinner
---@field frames? string[] Spinner animation frames
---@field text? string Text shown next to the spinner
---@field interval_ms? number Timer interval in ms (used by events.lua)

---@param _ CodeCompanion.Chat
---@param session CcuiSession
---@param opts CcuiComponentOpts.Spinner
---@return string
function M.spinner(_, session, opts)
  if not session.is_processing then
    return ''
  end

  local frames = opts.frames or { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  local text = opts.text or 'Processing...'
  local frame = frames[(session.spinner_idx % #frames) + 1]

  return frame .. ' ' .. text
end

---@param _ CodeCompanion.Chat
---@param session CcuiSession
---@param _ CcuiConfig.WinbarComponent
---@return string
function M.messages(_, session, _)
  if not session.message then
    return ''
  end
  return session.message.text
end

return M

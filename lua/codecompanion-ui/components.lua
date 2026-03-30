local M = {}

---@class CcuiComponentResult
---@field text string
---@field hl? string Highlight group name
---@field fg? string Foreground color (hex string)
---@field bg? string Background color (hex string)

---@alias CcuiComponentReturn CcuiComponentResult|string

---@class CcuiComponentOpts.Mode
---@field display_names? table<string, string> Rename modes for display
---@field icons? table<string, string> Icons per mode id

---For ACP adapters, show the agent mode
---@param chat CodeCompanion.Chat
---@param _ CcuiSession
---@param opts CcuiComponentOpts.Mode
---@return CcuiComponentReturn
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

  return { text = icon .. ' ' .. mode_name, hl = 'CcuiMode' }
end

---Show the adapter formatted name
---@param chat CodeCompanion.Chat
---@return CcuiComponentReturn
function M.adapter(chat)
  if chat.adapter then
    local name = chat.adapter.formatted_name or chat.adapter.name or ''
    if name ~= '' then
      return { text = name, hl = 'CcuiAdapter' }
    end
  end
  return ''
end

---Show the model formatted name
---@param chat CodeCompanion.Chat
---@return CcuiComponentReturn
function M.model(chat, _)
  local name = ''

  -- ACP adapter
  if chat.acp_connection and chat.acp_connection._models then
    local models = chat.acp_connection._models
    local current_id = models and models.currentModelId or ''
    for _, model in ipairs(models and models.availableModels or {}) do
      if model.modelId == current_id then
        name = model.name
        break
      end
    end
  end

  -- HTTP adapter
  if name == '' and chat.adapter and chat.adapter.model then
    local raw = chat.adapter.model.name
    local choices = chat.adapter.schema and chat.adapter.schema.model and chat.adapter.schema.model.choices
    if choices and choices[raw] and choices[raw].formatted_name then
      name = choices[raw].formatted_name
    else
      name = raw or ''
    end
  end

  if name ~= '' then
    return { text = '󰧑 ' .. name, hl = 'CcuiModel' }
  end
  return ''
end

---@class CcuiComponentOpts.Spinner
---@field frames? string[] Spinner animation frames
---@field text? string Text shown next to the spinner
---@field interval_ms? number Timer interval in ms (used by events.lua)

---Show a loading spinner for the current session
---@param _ CodeCompanion.Chat
---@param session CcuiSession
---@param opts CcuiComponentOpts.Spinner
---@return CcuiComponentReturn
function M.spinner(_, session, opts)
  if not session.is_processing then
    return ''
  end

  local frames = opts.frames or { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  local text = opts.text or 'Processing...'
  local frame = frames[(session.spinner_idx % #frames) + 1]

  return { text = frame .. ' ' .. text, hl = 'CcuiSpinner' }
end

---Show informational messages from the plugin
---@param _ CodeCompanion.Chat
---@param session CcuiSession
---@return CcuiComponentReturn
function M.messages(_, session)
  if not session.message then
    return ''
  end
  return { text = session.message.text, hl = session.message.hl or 'WarningMsg' }
end

---@class CcuiComponentOpts.ChatTitle
---@field icon? string Icon shown before the chat name; default: '󰭹'
---@field default? string The default text to show when no title; default: `[No Title]`

---Show the chat title
---@param chat CodeCompanion.Chat
---@param _ CcuiSession
---@param opts CcuiComponentOpts.ChatTitle
---@return CcuiComponentReturn
function M.chat_title(chat, _, opts)
  if not chat then
    return { text = '', hl = 'CcuiTitle' }
  end

  opts = opts or {}
  local icon = opts.icon or '󰭹'
  local title = chat.title or '[No Title]'
  -- %< truncate from end
  return { text = string.format('%s %s%%<', icon, title), hl = 'CcuiTitle' }
end

return M

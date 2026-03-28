local M = {}

---@class CcuiSession
---@field id number
---@field chat_bufnr number
---@field chat_winid number
---@field input_bufnr number|nil
---@field input_winid number|nil
---@field chat_at_bottom boolean
---@field is_processing boolean
---@field spinner_idx number
---@field spinner_timer uv.uv_timer_t|nil
---@field approval_keymaps string[]|nil
---@field message { text: string, hl: string }|nil
---@field _message_timer uv.uv_timer_t|nil

---@type table<number, CcuiSession>
M.sessions = {}

---@type number|nil
M.active_session_id = nil

---@param id number
---@param chat_bufnr number
---@param chat_winid number
---@return CcuiSession
function M.create(id, chat_bufnr, chat_winid)
  local session = {
    id = id,
    chat_bufnr = chat_bufnr,
    chat_winid = chat_winid,
    input_bufnr = nil,
    input_winid = nil,
    chat_at_bottom = true,
    is_processing = false,
    spinner_idx = 1,
    spinner_timer = nil,
  }
  M.sessions[id] = session
  M.active_session_id = id
  return session
end

---@param id number
---@return CcuiSession|nil
function M.get(id)
  return M.sessions[id]
end

---@param chat_bufnr number
---@return CcuiSession|nil
function M.get_by_bufnr(chat_bufnr)
  for _, session in pairs(M.sessions) do
    if session.chat_bufnr == chat_bufnr then
      return session
    end
  end
  return nil
end

---@param input_bufnr number
---@return CcuiSession|nil
function M.get_by_input_bufnr(input_bufnr)
  for _, session in pairs(M.sessions) do
    if session.input_bufnr == input_bufnr then
      return session
    end
  end
  return nil
end

---@return CcuiSession|nil
function M.active()
  if M.active_session_id then
    return M.sessions[M.active_session_id]
  end
  return nil
end

---@param session CcuiSession
---@param text string
---@param timeout? number Timeout in ms (default 1500). Pass 0 for no auto-clear.
function M.message(session, text, timeout)
  M.clear_message(session)
  session.message = { text = text, hl = 'WarningMsg' }
  local Events = require('codecompanion-ui.events')
  Events.redraw_winbar(session)
  timeout = timeout or 1500
  if timeout > 0 then
    session._message_timer = vim.defer_fn(function()
      if session.input_bufnr and vim.api.nvim_buf_is_valid(session.input_bufnr) then
        M.clear_message(session)
        Events.redraw_winbar(session)
      end
    end, timeout)
  end
end

---@param session CcuiSession
function M.clear_message(session)
  session.message = nil
  if session._message_timer then
    session._message_timer = nil
  end
end

---@param id number
function M.remove(id)
  local session = M.sessions[id]
  if session then
    if session.spinner_timer then
      session.spinner_timer:stop()
      session.spinner_timer:close()
      session.spinner_timer = nil
    end
    M.clear_message(session)
  end
  M.sessions[id] = nil
  if M.active_session_id == id then
    M.active_session_id = nil
  end
end

return M

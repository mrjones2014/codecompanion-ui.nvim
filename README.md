# codecompanion-ui.nvim

A custom UI extension for [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim)'s chat buffer
that provides a separate input window with a custom `winbar` to show information about the session.

https://github.com/user-attachments/assets/be7e1b78-1810-44a5-bc8a-e54264221023

## Features

- Separate input buffer below the chat window with markdown treesitter highlighting
- Rich winbar showing current mode, adapter, model, and a processing spinner
- Works with `codecompanion.nvim`'s auto-scroll functionality
- CodeCompanion chat keymaps work from the input buffer (including tool approvals)
- Completion support (adapters, models, slash commands) works in the input buffer
- Configurable spinner, window sizes, mode icons, and display names

## Requirements

- Neovim >= 0.10.0
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim), register the plugin as a CodeCompanion extension:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = { 'mrjones2014/codecompanion-ui.nvim' },
  opts = {
    extensions = {
      ui = {
        enabled = true,
        -- the default settings are shown here;
        -- you only need to specify non-default options
        opts = {
          input = {
            height = 10,
            -- Placeholder shown when the input buffer is empty
            placeholder = 'Type your message...',
            -- Message shown in winbar when user tries to submit while processing
            processing_blocked_message = 'Please wait...',
          },
          chat = {
            -- Chat window width as a fraction of the screen (0.0-1.0)
            width = 0.35,
          },
          spinner = {
            interval_ms = 100,
            frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
            text = 'Processing...',
          },
          -- Rename modes for display. Keys are the original mode name, values are the
          -- display name shown in the winbar.
          mode_display_names = {},
          mode_icons = {
            default = '',
            acceptEdits = '󱐋',
            plan = '󰙬',
            dontAsk = '󱐋',
            bypassPermissions = '󰒃',
          },
        },
      },
    },
  },
}
```

## License

[MIT](./LICENSE)

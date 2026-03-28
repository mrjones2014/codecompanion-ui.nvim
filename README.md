# codecompanion-ui.nvim

A custom UI extension for [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim)'s chat buffer
that provides a separate input window with a custom `winbar` to show information about the session.

![screenshot](https://github.com/user-attachments/assets/19b54a11-21a2-4245-a11c-879a67ab27d3)

## Features

- Separate input buffer below the chat window with markdown treesitter highlighting
- Customizable winbar with built-in components for model, provider, mode (for ACP adapter),
  loading spinner, and plugin messages
- Works with `codecompanion.nvim`'s auto-scroll functionality
- CodeCompanion chat keymaps work from the input buffer (including tool approvals)
- Completion support (adapters, models, slash commands) works in the input buffer
- Configurable progress spinner, window sizes, mode icons, and display names

## Requirements

- Neovim >= 0.10.0
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim), register the plugin as a CodeCompanion extension:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'mrjones2014/codecompanion-ui.nvim',
    {
      -- optional, but highly recommended
      -- `render-markdown.nvim` will auto-attach to lazy.nvim `ft` filetypes
      'MeanderingProgrammer/render-markdown.nvim',
      ft = { 'codecompanion', 'codecompanion-ui' },
    },
  },
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
            -- set to `{}` to disable,
            -- see `./lua/codecompanion-ui/components.lua`
            -- for built in components and their options.
            -- feel free to put up a PR with more components!
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
              -- shows some status messages from the plugin briefly
              { component = 'messages' },
            },
          },
          chat = {
            -- Chat window width as a fraction of the screen (0.0-1.0)
            width = 0.35,
          },
        },
      },
    },
  },
}
```

## License

[MIT](./LICENSE)

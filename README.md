# neogit-ai-commit.nvim

Generate Conventional Commit messages for staged changes from a `gitcommit` buffer.

This plugin reads the staged diff through Neogit, sends it to an OpenAI-compatible chat completions endpoint, and replaces the current commit message buffer with a single-line commit message suggestion.

## Requirements

- Neovim
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)
- An API key for an OpenAI-compatible provider

## Installation

### lazy.nvim

```lua
{
  "joacolabadie/neogit-ai-commit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "NeogitOrg/neogit",
  },
  config = function()
    require("neogit-ai-commit").setup()
  end,
}
```

## Configuration

Default configuration:

```lua
require("neogit-ai-commit").setup({
  api_key = nil,
  env_var = "OPENAI_API_KEY",
  api_url = "https://api.openai.com/v1/chat/completions",
  model = "gpt-5-mini",
  max_completion_tokens = nil,
})
```

### Options

- `api_key`: API key string. If unset, the plugin reads from `env_var`.
- `env_var`: Environment variable used when `api_key` is not provided.
- `api_url`: Chat Completions endpoint. Useful for OpenAI-compatible providers.
- `model`: Model name sent in the request body.
- `max_completion_tokens`: Optional token cap passed through to the API request.

## Usage

1. Stage your changes.
2. Open a commit message buffer, for example through Neogit.
3. Press `<leader>cm` in normal mode.

The plugin will:

- read the staged diff with `git diff --cached`
- ask the model for a single-line Conventional Commit message
- replace the current commit buffer contents with the generated result

## Keymap

The plugin defines this buffer-local mapping for `gitcommit` buffers:

```lua
<leader>cm
```

If you prefer a custom mapping, call `generate()` yourself:

```lua
vim.keymap.set("n", "<leader>am", function()
  require("neogit-ai-commit").generate(vim.api.nvim_get_current_buf())
end, { desc = "Generate AI commit message" })
```

You can also override options for a single request:

```lua
require("neogit-ai-commit").generate(vim.api.nvim_get_current_buf(), {
  model = "gpt-5",
})
```

## Notes

- Only staged changes are used as input.
- The generated message is intended to be a single-line Conventional Commit.
- On failure, the plugin notifies through `vim.notify()`.
- The current implementation creates the default mapping for every `gitcommit` buffer when `setup()` is called.

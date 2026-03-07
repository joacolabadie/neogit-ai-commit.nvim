# neogit-ai-commit.nvim

Generate AI-powered **Conventional Commit messages** for staged changes directly from a `gitcommit` buffer.

This plugin reads the staged diff through **Neogit**, sends it to the **OpenAI Chat Completions API**, and replaces the current commit message buffer with a single-line commit message suggestion.

The generated message follows the **Conventional Commits** format.

---

# Requirements

- Neovim
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)
- An OpenAI API key

---

# Installation

## lazy.nvim

```lua
{
  "joacolabadie/neogit-ai-commit.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "NeogitOrg/neogit",
  },
  opts = {},
}

---

# Configuration

The plugin works out of the box with the default configuration.

You can override any option using `opts` when installing the plugin with `lazy.nvim`.

Example:

```lua
{
  "joacolabadie/neogit-ai-commit.nvim",
  opts = {
    model = "gpt-5-mini",
    max_completion_tokens = 100,
  },
}
```

## Default Configuration

```lua
{
  api_key = nil,
  env_var = "OPENAI_API_KEY",
  api_url = "https://api.openai.com/v1/chat/completions",
  model = "gpt-5-mini",
  max_completion_tokens = nil,
}
```

## Options

| Option | Description |
|------|-------------|
| `api_key` | OpenAI API key. If not set, the plugin reads from `env_var`. |
| `env_var` | Environment variable used when `api_key` is not provided. |
| `api_url` | OpenAI Chat Completions endpoint. |
| `model` | Model used to generate the commit message. |
| `max_completion_tokens` | Optional limit for generated tokens. |

---

# API Key Setup

The plugin expects your OpenAI API key to be available as an environment variable.

By default it reads:

```
OPENAI_API_KEY
```

### Ubuntu / Linux

Add this to your `~/.bashrc`:

```bash
export OPENAI_API_KEY="your_api_key_here"
```

Reload your shell:

```bash
source ~/.bashrc
```

Alternatively you can provide the key directly in the plugin configuration:

```lua
{
  "joacolabadie/neogit-ai-commit.nvim",
  opts = {
    api_key = "your_api_key_here",
  },
}
```

---

# Usage

1. Stage your changes.

```bash
git add .
```

2. Open a commit message buffer (for example through **Neogit**).

3. Press the keymap below to generate a commit message.

---

# Keymap

The plugin defines a buffer-local mapping for `gitcommit` buffers:

```
<leader>cm
```

Press this inside a commit message buffer to generate an AI commit message based on the staged changes.

# Notes

- Only **staged changes** are used as input.
- The generated message follows the **Conventional Commits** format.
- The commit message buffer will be **replaced with the generated suggestion**.
- If the API request fails, the plugin reports the error using `vim.notify()`.
- The keymap is created automatically for every `gitcommit` buffer when the plugin loads.

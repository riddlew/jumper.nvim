# Jumper

A telescope plugin that lets you save, edit, re-arrange, and jump to files and directories. Like [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim), but with more freedom.

## Installation

```lua
-- Packer
use 'xorid/jumper.nvim'
```

## Setup
```lua
require("jumper").setup()

-- Defaults:
defaults = {
	-- Default save file location within stdpath("config"). For example,
	-- ~/.config/nvim/jumper.json.
	save_file = "jumper.json"
}
```

## Usage

`:Telescope jumper`

| Keybind   | Description                                                      |
| --------- | -------------                                                    |
| `<C-a>`   | Add a new path / file                                            |
| `<C-d>`   | Delete selected path / file                                      |
| `<C-e>`   | Edit selected path / file                                        |
| `<C-s>`   | Swap the position of two selected files (using multi-select)[^1] |

[^1]: I originally planned to control the positions using `<C-j>`/`<C-k>` to move lines up and down. However, I do not know of a way to refresh the picker without causing the selected lines to jump back to the top. If you know of a solution, please let me know. PRs would also be welcomed.

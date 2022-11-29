# Jumper

A telescope plugin that lets you save, edit, re-arrange, and jump to files and directories. Like [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim), but with more freedom.

## How is it different than telescope-project.nvim?

| Telescope-project                                                                             | Jumper                                                                                                             |
|-----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| Does not save paths to individual files, only directories.                                    | Saves paths to any file or directory.                                                                              |
| Does not prompt for a directory and chooses either the git root or current working directory. | Saves any directory you choose, even within a git root folder.                                                     |
| Cannot save a directory unless the user is currently in the directory.                        | User is prompted for the directory, so you can add any directory at any location without having to CD to it first.

## Why use it?

When I originally tried telescope-project, I had several directories that I often used that could not be added since they are part of a large repo. For example, my dotfiles folder currently uses `stow` and looks something like this:

```
dotfiles (git root)
├── common
│   ├── fonts
│   │   └── .fonts
│   └── nvim
│       └── .config
│           └── nvim
└── linux
    ├── alacritty
    │   └── .config
    │       └── alacritty
    │           └── alacritty.yml
    ├── git
    └── rofi
```

If I want to navigate to my nvim folder, that would require navigating at least 4 directories to reach my nvim config. While I often use telescope's oldfiles to open files such as this, sometimes it may end up being removed if I'm opening a lot of files. And since telescope-project only saves the git root, I have no way of easily reaching my nvim folder.

After creating jumper.nvim, I can save any directory I want such as dotfiles/common/nvim/.config/nvim. I am not limited to only the git root.

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

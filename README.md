# ProjectMgr

> Quickly switch between projects and define custom startup commands for each.

1. [What problem does this plugin solve?](#what-problem-does-this-plugin-solve)
2. [Demo](#demo)
3. [Installation](#installation)
    - [With packer](#with-packer)
    - [With other plugin managers](#with-other-plugin-managers)
4. [Commands & Functions](#commands--functions)

## What problem does this plugin solve?

If you have a lot of projects you work on simultaneously, you are frequently switching between these projects.
Often times, these projects will require some command(s) to be run every time you work on them - starting a webserver, activating a python virtual environment, or even just fetching and pulling changes.

This plugin allows you to define projects and an associated command. At the press of a button, the working directory is changed to that of your project and the startup command is executed,
thus significantly simplifying and speeding up some of the most common steps you take every time you open (neo)vim.

## Demo

The demo first shows the creation of a new project, then the opening of the same project.
![Demo Gif](https://raw.githubusercontent.com/charludo/projectmgr.nvim/main/demo.gif)

## Installation

### With packer

```lua
use {
  'charludo/projectmgr.nvim',
  rocks = {'lsqlite3'},
}
```

### With other plugin managers

Not tested, sorry. Should work as usual though - just remember to manually install the dependency (lsqlite3) through luarocks.

## Commands & Functions

The plugin adds one command: `:ProjectMgr` opens the ProjectMgr-window. I recommend to rebind the command to `<leader>P` or similar.

Once inside the window, the following keybinds become active:

Key | Action
:--- | :---
`a` | Add a project. You will be asked for a name, a path, and optionally a command.
`<CR>` | Open the project under your cursor
`d` / `x` | Delete project under your cursor
`e` / `u` | Edit the project under your cursor
`q` / `<ESC>` | Close the window without doing anything



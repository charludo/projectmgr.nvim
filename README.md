<p align="center">
  <h2 align="center">📚 projectmgr.nvim</h2>
</p>

<p align="center">
	Quickly switch between projects and automate startup tasks
</p>

<p align="center">
	<a href="https://github.com/charludo/projectmgr.nvim/stargazers">
		<img alt="Stars" src="https://img.shields.io/github/stars/charludo/projectmgr.nvim?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=F3B562&labelColor=302D41"></a>
	<a href="https://github.com/charludo/projectmgr.nvim/issues">
		<img alt="Issues" src="https://img.shields.io/github/issues/charludo/projectmgr.nvim?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=F06060&labelColor=302D41"></a>
	<a href="https://github.com/charludo/projectmgr.nvim">
		<img alt="Size" src="https://img.shields.io/github/repo-size/charludo/projectmgr.nvim?color=8CBEB2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41"/></a>
</p>

&nbsp;

### 📜 Features

- create a list of projects, then quickly switch between them
- automate startup and shutdown tasks for each project:
  - git fetch && git pull when entering the project
  - custom startup command and/or script
  - custom shutdown command and/or script
- save and restore sessions and shada files on a per-project base
- reopen last opened project (if you exited vim from within a project)
- freely configurable, disable any unwanted feature(s)

&nbsp;

### 📽 Demo

![Demo Gif](https://raw.githubusercontent.com/charludo/projectmgr.nvim/main/demo.gif)

&nbsp;

### 📦 Installation

The plugin is intended for use with packer, since a `luarocks` dependency exists:

```lua
use {
  'charludo/projectmgr.nvim',
  rocks = {'lsqlite3'},
}
```

&nbsp;

### ⚙️ Configuration

**projectmgr** default configuration:

```lua
{
    autogit = false,
	reopen = false,
	session = { enabled = true, file = "Session.vim" },
	shada = { enabled = false, file = "main.shada" },
	scripts = {
		enabled = true,
		file_startup = "startup.sh",
		file_shutdown = "shutdown.sh",
	},
}
```

It's recommended to set up a key mapping to toggle the projectmgr window:

```lua
vim.api.nvim_set_keymap("n", "<leader>p", ":ProjectMgr<CR>", {})
```

&nbsp;

### 🦑 Usage

`:ProjectMgr` (or your keybind) toggles the projectmgr window. Here you can perform the following actions:

| Key           | Action                                                                                             |
| :------------ | :------------------------------------------------------------------------------------------------- |
| `<CR>`        | Open the project under your cursor                                                                 |
| `a`           | Add a project. You will be asked for a name, a path, and optionally startup and shutdown commands. |
| `d` / `x`     | Delete project under your cursor                                                                   |
| `e` / `u`     | Edit the project under your cursor                                                                 |
| `q` / `<ESC>` | Close the window without doing anything                                                            |

&nbsp;

<p align="center">
  <h2 align="center">📚 projectmgr.nvim</h2>
</p>

<p align="center">
	Quickly switch between projects and automate startup tasks
</p>

<p align="center">
	<a href="https://github.com/charludo/projectmgr.nvim/stargazers">
		<img alt="Stars" src="https://img.shields.io/github/stars/charludo/projectmgr.nvim?style=for-the-badge&logo=starship&color=F3B562&logoColor=D9E0EE&labelColor=302D41"></a>
	<a href="https://github.com/charludo/projectmgr.nvim/issues">
		<img alt="Issues" src="https://img.shields.io/github/issues/charludo/projectmgr.nvim?style=for-the-badge&logo=bilibili&color=F06060&logoColor=D9E0EE&labelColor=302D41"></a>
	<a href="https://github.com/charludo/projectmgr.nvim">
		<img alt="Size" src="https://img.shields.io/github/repo-size/charludo/projectmgr.nvim?color=8CBEB2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41"/></a>
</p>

&nbsp;

### 📜 Features

- create a list of projects, then quickly switch between them
- automate startup and shutdown tasks for each project:
  - pull from a remote when entering the project
  - custom startup command and/or script
  - custom shutdown command and/or script
- save and restore sessions and shada files on a per-project base
- reopen last opened project (if you exited vim from within a project)
- freely configurable, disable any unwanted feature(s)
- if you are already using [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), this plugin will integrate with it OOTB

&nbsp;

### 📽 Demo

![Demo Gif](https://raw.githubusercontent.com/charludo/media-storage/main/demo.gif)

&nbsp;

### 📦 Installation

The plugin is straightforward to install, so feel free to use your favorite plugin manager, e.g.:

**Packer:**

```lua
use { 'charludo/projectmgr.nvim' }
```

**Lazy:**

```lua
{
  'charludo/projectmgr.nvim',
  lazy = false, -- important!
}
```

&nbsp;

### ⚙️ Configuration

**projectmgr** default configuration:

```lua
{
  autogit = {
    enabled = false,
    command = "git pull --ff-only",
  },
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

It's a good idea to set up a key mapping to toggle the projectmgr window:

```lua
vim.api.nvim_set_keymap("n", "<leader>p", ":ProjectMgr<CR>", {})
```

&nbsp;

### 🦑 Usage with `telescope.nvim`

`:ProjectMgr` (or your keybind) toggles a telescope picker with your projects. The telescope preview displays information about your project
and its current git state. (I'm very much open to adding more info here and am happy about suggestions!)

The following actions and keybinds are available:

| Key               | Action                                                                                             |
| :---------------- | :------------------------------------------------------------------------------------------------- |
| `<CR>`            | Open the project under your cursor                                                                 |
| `<C-a>`           | Add a project. You will be asked for a name, a path, and optionally startup and shutdown commands. |
| `<C-d>` / `<C-x>` | Delete project under your cursor                                                                   |
| `<C-e>` / `<C-u>` | Edit the project under your cursor                                                                 |
| `<C-q>` / `<ESC>` | Close the window without doing anything                                                            |

&nbsp;

### 🦑 Usage without `telescope.nvim`

**projectmgr** comes with a fallback window in case you aren't using `telescope.nvim`. The same actions are available.
The keybinds are slightly different: `<C-a>` is replaced by just `a`, `<C-q>` becomes just `q`, and so on.

&nbsp;

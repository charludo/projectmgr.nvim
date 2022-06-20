" Title:        ProjectManager
" Description:  Quickly switch between projects and execute custom startup
" commands for each.
" Last Change:  16 June 2022
" Maintainer:   Charlotte Hartmann Paludo <https://github.com/charludo>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_projectmgr")
    finish
endif
let s:save_cpo = &cpo " save user coptions
set cpo&vim

hi def link ProjectmgrHeader      Number

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/projectmgr/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 Project lua require("projectmgr").show_selection()
command! -nargs=0 ProjectCreate lua require("projectmgr").create_project()

let &cpo = s:save_cpo " restore user coptions
unlet s:save_cpo

let g:loaded_projectmgr = 1

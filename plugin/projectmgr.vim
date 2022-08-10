" Title:        ProjectManager
" Description:  Quickly switch between projects and execute custom startup
" commands for each.
" Last Change:  07 August 2022
" Maintainer:   Charlotte Hartmann Paludo <https://github.com/charludo>

if exists("g:loaded_projectmgr")
    finish
endif
let s:save_cpo = &cpo
set cpo&vim

hi def link ProjectmgrHeader      Number

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/projectmgr/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

command! -nargs=0 ProjectMgr lua require("projectmgr").open_window()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_projectmgr = 1

augroup ProjectMgrGroup
    autocmd!
    autocmd VimEnter * nested lua require("projectmgr").startup()
    autocmd VimLeavePre * lua require("projectmgr").shutdown()
augroup END

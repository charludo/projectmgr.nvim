-- Imports the plugin's additional Lua modules.
-- local switch = require("projectmgr.switch")
local fetch = require("projectmgr.fetch")
-- local update = require("projectmgr.update")



local api = vim.api
local buf, win
local position = 0

local function center(str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

local function open_window()
    buf = api.nvim_create_buf(false, true)
    local border_buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'filetype', 'whid')

    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- calculate our floating window size
    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    -- and its starting position
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- set some options
    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col
    }

    -- and finally create it with buffer attached
    win = api.nvim_open_win(buf, true, opts)

    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 2,
        row = row - 1,
        col = col - 1
    }


    local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    for _=1, win_height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
    api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    local border_win = api.nvim_open_win(border_buf, true, border_opts)
    win = api.nvim_open_win(buf, true, opts)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

    api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

    -- we can add title already here, because first line will never change
    api.nvim_buf_set_lines(buf, 0, -1, false, { center('Projects'), '', ''})
    api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

local function update_view(direction)
    api.nvim_buf_set_option(buf, 'modifiable', true)
    position = position + direction
    if position < 0 then position = 0 end

    local result = fetch.get_projects()[position]
    for k,_ in pairs(result) do
        result[k] = '  '..result[k]
    end

    api.nvim_buf_set_lines(buf, 1, 2, false, {center('Projects')})
    api.nvim_buf_set_lines(buf, 3, -1, false, result)

    api.nvim_buf_add_highlight(buf, -1, 'whidSubHeader', 1, 0, -1)
    api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function close_window()
    api.nvim_win_close(win, true)
end

local function open_file()
    local str = api.nvim_get_current_line()
    close_window()
    api.nvim_command('cd '..str)
end

local function move_cursor()
    local new_pos = math.max(4, api.nvim_get_cursor(win)[1] - 1)
    api.nvim_win_set_cursor(win, {new_pos, 0})
end

local function set_mappings()
    local mappings = {
        ['['] = 'update_view(-1)',
        [']'] = 'update_view(1)',
        ['<cr>'] = 'open_file()',
        h = 'update_view(-1)',
        l = 'update_view(1)',
        q = 'close_window()',
        k = 'move_cursor()'
    }

    for k,v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"whid".'..v..'<cr>', {
            nowait = true, noremap = true, silent = true
        })
    end
    local other_chars = {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    }
    for _,v in ipairs(other_chars) do
        api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
    end
end

local function whid()
    position = 0
    open_window()
    set_mappings()
    update_view(0)
    api.nvim_win_set_cursor(win, {4, 0})
end

return {
    whid = whid,
    update_view = update_view,
    open_file = open_file,
    move_cursor = move_cursor,
    close_window = close_window
}

-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.
-- local M = {}

-- Routes calls made to this module to functions in the
-- plugin's other modules.
-- M.switch_project = switch.switch_project
-- M.get_projects = fetch.get_projects
-- M.create_project = update.create_project
-- M.delete_project = update.delete_project

-- return M

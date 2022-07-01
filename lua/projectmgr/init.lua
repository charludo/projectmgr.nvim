-- Imports the plugin's additional Lua modules.
local fetch = require("projectmgr.fetch")
local update = require("projectmgr.update")



local api = vim.api
local buf, win
local position = 0

local M = {}

local default_config = {
    autogit = false,
    reopen = false,
    session = {
        enabled = true,
        file = "Session.vim",
    },
    shada = {
        enabled = false,
        file = "main.shada",
    },
    scripts = {
        enabled = true,
        file_startup = "startup.sh",
        file_shutdown = "shutdown.sh",
    },
}

function M.setup(config)
    config = config or {}
    vim.validate {
        autogit  = { config.autogit, 'b', true },
        reopen = { config.reopen, 'b', true },
        session = { config.session, 't', true},
        shada = { config.shada, 't', true},
        scripts = { config.scripts, 't', true},
    }

    M.config = vim.tbl_extend("keep", config, default_config)

    vim.api.nvim_exec([[
        augroup ProjectMgrGroup
            autocmd!
            autocmd VimEnter * lua require("projectmgr").startup()
            autocmd VimLeavePre * lua require("projectmgr").shutdown()
        augroup END
    ]], false)
end


local function open_window()
    buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'filetype', 'projectmgr')

-- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- calculate our floating window size
    local win_height = math.ceil(20)
    -- local win_height = math.ceil(height * 0.25 - 4)
    local win_width = math.ceil(35)
    -- local win_width = math.ceil(width * 0.15)

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
        col = col,
        border = {"╔", "═" ,"╗", "║", "╝", "═", "╚", "║"}
    }

    -- and finally create it with buffer attached
    win = api.nvim_open_win(buf, true, opts)
    api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

    -- we can add title already here, because first line will never change
    api.nvim_buf_set_lines(buf, 0, -1, false, { ' [Projects]', '', ''})
    api.nvim_buf_add_highlight(buf, -1, 'ProjectmgrHeader', 0, 0, -1)
end

local function update_view(direction)
    api.nvim_buf_set_option(buf, 'modifiable', true)
    position = position + direction
    if position < 1 then position = 1 end
    local count_entries = 0

    local flattened = fetch.get_projects()
    for k,_ in pairs(flattened) do
        flattened[k] = '  '..flattened[k]
        count_entries = count_entries + 1
    end

    api.nvim_buf_set_lines(buf, 3, -1, false, flattened)
    api.nvim_buf_set_option(buf, 'modifiable', false)

    if count_entries>0 then
        api.nvim_win_set_cursor(win, {4, 0})
    -- else
        -- api.nvim_win_set_cursor(win, {0, 0})
    end
end

local function close_window()
    api.nvim_win_close(win, true)
end

local function set_mappings()
    local mappings = {
        -- ['['] = 'update_view(-1)',
        -- [']'] = 'update_view(1)',
        ['<cr>'] = 'open_project()',
        ['x'] = 'delete_project()',
        ['d'] = 'delete_project()',
        ['e'] = 'handle_update()',
        ['u'] = 'handle_update()',
        ['a'] = 'handle_create()',
        -- h = 'update_view(-1)',
        -- l = 'update_view(1)',
        ['q'] = 'close_window()',
        ['<ESC>'] = 'close_window()',
    }

    for k,v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"projectmgr".'..v..'<cr>', {
            nowait = true, noremap = true, silent = true
        })
    end
    local other_chars = {
        'b', 'c', 'f', 'g', 'i', 'm', 'n', 'o', 'p', 'r', 's', 't', 'v', 'w', 'y', 'z'
    }
    for _,v in ipairs(other_chars) do
        api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
    end
end

local function file_exists(name)
    local f = io.open(name, "r")
    if f~=nil then io.close(f) return true else return false end
end

local function get_name()
    local str = api.nvim_get_current_line()
    local name = str:match'^%s*(.*)'
    return name
end

local function delete_project()
    update.delete_project(get_name())
    update_view(0)
end

local function execute_command(command)
    if command == nil then return end
    if command:find('^!') ~= nil then
        local _ = io.popen(string.sub(command,2))
    else
        api.nvim(command)
    end
end

local function execute_script(filename)
    if file_exists(filename) then
        local _ = io.popen('./'..filename)
    end
end

local function close_project()
    local _,_,command = fetch.get_single_project(fetch.get_current_project())

    -- if so configured, save Session and shada
    if M.config.session.enabled then
        api.nvim_command('set sessionoptions-=options')
        api.nvim_command('mksession! '..M.config.session.file)
    end
    if M.config.shada.enabled then
        api.nvim_command('wshada! '..M.config.shada.file)
    end
    -- execute custom exit command
    execute_command(command)

    -- execute shutdown script
    execute_script(M.config.scripts.file_shutdown)

end

local function open_project(reopen)
    local new_wd,command,_ = nil,nil,nil

    if reopen == nil then
        -- IF: opened via selection screen
        -- first: close the current project
        close_project()
        -- then: set the project about to be opened as the new current
        update.set_current_project(get_name())

        new_wd,command,_ = fetch.get_single_project(get_name())
        close_window()
    elseif reopen == "-1" then
        -- no current project exists, and we are not at the selection screen
        return
    else
        -- IF: called by startup function
        new_wd,command,_ = fetch.get_single_project(fetch.get_current_project())
    end

    if new_wd ~= nil then
        -- change to project dir
        api.nvim_command('cd '..new_wd)

        -- check if autogit is set and if inside worktree
        if M.config.autogit then
            local is_git = false
            local handle = io.popen("git rev-parse --is-inside-work-tree")
            if handle ~= nil then
                local check_result = handle:read("*a")
                if string.find(check_result, "true") then is_git = true end
                handle:close()
            end

            if is_git then
                local _ = io.popen("git fetch && git pull")
                print("[ProjectMgr] git repo found, fetching && pulling...")
            end
        end

        -- check for session and shada file names;
        -- if they exist, source them
        if M.config.session.enabled and file_exists(M.config.session.file) then
            api.nvim_command('so '..M.config.session.file)
            vim.api.nvim_exec([[
                if bufexists(1)
                for l in range(1, bufnr('$'))
                    if bufwinnr(l) == -1
                    exec 'sbuffer ' . l
                    endif
                endfor
                endif
            ]], false)
        end

        if M.config.shada.enabled and file_exists(M.config.shada) then
            api.nvim_command('rshada '..M.config.shada.file)
        end

        -- execute custom command
        execute_command(command)

        -- execute startup script
        execute_script(M.config.scripts.file_startup)
    end
end

local function handle_update()
    local old_name = get_name()
    local old_pos = api.nvim_win_get_cursor(0)

    close_window()
    update.update_project(old_name)

    open_window()
    set_mappings()
    update_view(0)
    api.nvim_win_set_cursor(win, old_pos)
end

local function handle_create()
    close_window()
    update.create_project()

    open_window()
    set_mappings()
    update_view(0)
end

local function show_selection()
    position = 0
    open_window()
    set_mappings()
    update_view(0)
end

local function shutdown()
    close_project()
end

local function startup()
    update.prepare_db()
    if M.config.reopen then
        local current = fetch.get_current_project()
        if current == nil then
            current = "-1"
        end
        open_project(current)
    end
end





-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.

-- Routes calls made to this module to functions in the
-- plugin's other modules.
M.show_selection = show_selection
M.open_project = open_project
M.delete_project = delete_project
M.close_window = close_window
M.handle_update = handle_update
M.handle_create = handle_create
M.startup = startup
M.shutdown = shutdown
return M

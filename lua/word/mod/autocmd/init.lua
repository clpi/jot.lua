--[[
    file: autocmd
    summary: Handles the creation and management of Neovim's autocmd.
    description: Handles the creation and management of Neovim's autocmd.
    internal: true
    ---
This internal init exposes functionality for subscribing to autocmd and performing actions based on those autocmd.

###### NOTE: This init will be soon deprecated, and it's favourable to use the `vim.api*` functions instead.

In your `init.setup()`, make sure to require `base.autocmd` (`requires = { "autocmd" }`)
Afterwards in a function of your choice that gets called *after* base.autocommmands gets intialized (e.g. `load()`):

```lua
init.load = function()
    init.required["autocmd"].enable_autocommand("VimLeavePre") -- Substitute VimLeavePre for any valid neovim autocommand
end
```

Afterwards, be sure to subscribe to the event:

```lua
init.events.subscribed = {
    ["autocmd"] = {
        vimleavepre = true
    }
}
```

Upon receiving an event, it will come in this format:
```lua
{
    type = "autocmd.events.<name of autocommand, e.g. vimleavepre>",
    broadcast = true
}
```
--]]

local word = require("word")
local log, mod = word.log, word.mod

local init = mod.create("autocmd")

--- This function gets invoked whenever a base.autocmd enabled autocommand is triggered. Note that this function should be only used internally
---@param name string #The name of the autocommand that was just triggered
---@param triggered_from_word boolean #If true, that means we have received this event as part of a *.word autocommand
---@param ev? table the original event data
function _word_init_autocommand_triggered(name, triggered_from_word, ev)
    local event = mod.create_event(init, name, { word = triggered_from_word }, ev)
    assert(event)
    mod.broadcast_event(event)
end

-- A convenience wrapper around mod.define_event_event
init.private.autocmd_base = function(name)
    return mod.define_event(init, name)
end

---@class base.autocmd
init.public = {

    --- By base, all autocmd are disabled for performance reasons. To enable them, use this command. If an invalid autocmd is given nothing happens.
    ---@param autocmd string #The relative name of the autocommand to enable
    ---@param dont_isolate boolean #base to false. Specifies whether the autocommand should run globally (* instead of in word files (*.word)
    enable_autocommand = function(autocmd, dont_isolate)
        dont_isolate = dont_isolate or false

        autocmd = autocmd:lower()
        local subscribed_autocommand = init.events.subscribed["autocmd"][autocmd]

        if subscribed_autocommand ~= nil then
            vim.cmd("augroup word")

            if dont_isolate and vim.fn.exists("#word#" .. autocmd .. "#*") == 0 then
                vim.api.nvim_create_autocmd(autocmd, {
                    callback = function(ev)
                        _word_init_autocommand_triggered("autocmd.events." .. autocmd, false, ev)
                    end,
                })
            elseif vim.fn.exists("#word#" .. autocmd .. "#*.word") == 0 then
                vim.api.nvim_create_autocmd(autocmd, {
                    pattern = "*.word",
                    callback = function(ev)
                        _word_init_autocommand_triggered("autocmd.events." .. autocmd, true, ev)
                    end,
                })
            end
            vim.cmd("augroup END")
            init.events.subscribed["autocmd"][autocmd] = true
        end
    end,

    version = "0.0.8",
}

-- All the subscribeable events for base.autocmd
init.events.subscribed = {

    ["autocmd"] = {

        bufadd = false,
        bufdelete = false,
        bufenter = false,
        buffilepost = false,
        buffilepre = false,
        bufhidden = false,
        bufleave = false,
        bufmodifiedset = false,
        bufnew = false,
        bufnewfile = false,
        bufreadpost = false,
        bufreadcmd = false,
        bufreadpre = false,
        bufunload = false,
        bufwinenter = false,
        bufwinleave = false,
        bufwipeout = false,
        bufwrite = false,
        bufwritecmd = false,
        bufwritepost = false,
        chaninfo = false,
        chanopen = false,
        cmdundefined = false,
        cmdlinechanged = false,
        cmdlineenter = false,
        cmdlineleave = false,
        cmdwinenter = false,
        cmdwinleave = false,
        colorscheme = false,
        colorschemepre = false,
        completechanged = false,
        completedonepre = false,
        completedone = false,
        cursorhold = false,
        cursorholdi = false,
        cursormoved = false,
        cursormovedi = false,
        diffupdated = false,
        dirchanged = false,
        fileappendcmd = false,
        fileappendpost = false,
        fileappendpre = false,
        filechangedro = false,
        exitpre = false,
        filechangedshell = false,
        filechangedshellpost = false,
        filereadcmd = false,
        filereadpost = false,
        filereadpre = false,
        filetype = false,
        filewritecmd = false,
        filewritepost = false,
        filewritepre = false,
        filterreadpost = false,
        filterreadpre = false,
        filterwritepost = false,
        filterwritepre = false,
        focusgained = false,
        focuslost = false,
        funcundefined = false,
        uienter = false,
        uileave = false,
        insertchange = false,
        insertcharpre = false,
        textyankpost = false,
        insertenter = false,
        insertleavepre = false,
        insertleave = false,
        menupopup = false,
        optionset = false,
        quickfixcmdpre = false,
        quickfixcmdpost = false,
        quitpre = false,
        remotereply = false,
        sessionloadpost = false,
        shellcmdpost = false,
        signal = false,
        shellfilterpost = false,
        sourcepre = false,
        sourcepost = false,
        sourcecmd = false,
        spellfilemissing = false,
        stdinreadpost = false,
        stdinreadpre = false,
        swapexists = false,
        syntax = false,
        tabenter = false,
        tableave = false,
        tabnew = false,
        tabnewentered = false,
        tabclosed = false,
        termopen = false,
        termenter = false,
        termleave = false,
        termclose = false,
        termresponse = false,
        textchanged = false,
        textchangedi = false,
        textchangedp = false,
        user = false,
        usergettingbored = false,
        vimenter = false,
        vimleave = false,
        vimleavepre = false,
        vimresized = false,
        vimresume = false,
        vimsuspend = false,
        winclosed = false,
        winenter = false,
        winleave = false,
        winnew = false,
        winscrolled = false,
    },
}

-- All the autocommand definitions
init.events.defined = {

    bufadd = init.private.autocmd_base("bufadd"),
    bufdelete = init.private.autocmd_base("bufdelete"),
    bufenter = init.private.autocmd_base("bufenter"),
    buffilepost = init.private.autocmd_base("buffilepost"),
    buffilepre = init.private.autocmd_base("buffilepre"),
    bufhidden = init.private.autocmd_base("bufhidden"),
    bufleave = init.private.autocmd_base("bufleave"),
    bufmodifiedset = init.private.autocmd_base("bufmodifiedset"),
    bufnew = init.private.autocmd_base("bufnew"),
    bufnewfile = init.private.autocmd_base("bufnewfile"),
    bufreadpost = init.private.autocmd_base("bufreadpost"),
    bufreadcmd = init.private.autocmd_base("bufreadcmd"),
    bufreadpre = init.private.autocmd_base("bufreadpre"),
    bufunload = init.private.autocmd_base("bufunload"),
    bufwinenter = init.private.autocmd_base("bufwinenter"),
    bufwinleave = init.private.autocmd_base("bufwinleave"),
    bufwipeout = init.private.autocmd_base("bufwipeout"),
    bufwrite = init.private.autocmd_base("bufwrite"),
    bufwritecmd = init.private.autocmd_base("bufwritecmd"),
    bufwritepost = init.private.autocmd_base("bufwritepost"),
    chaninfo = init.private.autocmd_base("chaninfo"),
    chanopen = init.private.autocmd_base("chanopen"),
    cmdundefined = init.private.autocmd_base("cmdundefined"),
    cmdlinechanged = init.private.autocmd_base("cmdlinechanged"),
    cmdlineenter = init.private.autocmd_base("cmdlineenter"),
    cmdlineleave = init.private.autocmd_base("cmdlineleave"),
    cmdwinenter = init.private.autocmd_base("cmdwinenter"),
    cmdwinleave = init.private.autocmd_base("cmdwinleave"),
    colorscheme = init.private.autocmd_base("colorscheme"),
    colorschemepre = init.private.autocmd_base("colorschemepre"),
    completechanged = init.private.autocmd_base("completechanged"),
    completedonepre = init.private.autocmd_base("completedonepre"),
    completedone = init.private.autocmd_base("completedone"),
    cursorhold = init.private.autocmd_base("cursorhold"),
    cursorholdi = init.private.autocmd_base("cursorholdi"),
    cursormoved = init.private.autocmd_base("cursormoved"),
    cursormovedi = init.private.autocmd_base("cursormovedi"),
    diffupdated = init.private.autocmd_base("diffupdated"),
    dirchanged = init.private.autocmd_base("dirchanged"),
    fileappendcmd = init.private.autocmd_base("fileappendcmd"),
    fileappendpost = init.private.autocmd_base("fileappendpost"),
    fileappendpre = init.private.autocmd_base("fileappendpre"),
    filechangedro = init.private.autocmd_base("filechangedro"),
    exitpre = init.private.autocmd_base("exitpre"),
    filechangedshell = init.private.autocmd_base("filechangedshell"),
    filechangedshellpost = init.private.autocmd_base("filechangedshellpost"),
    filereadcmd = init.private.autocmd_base("filereadcmd"),
    filereadpost = init.private.autocmd_base("filereadpost"),
    filereadpre = init.private.autocmd_base("filereadpre"),
    filetype = init.private.autocmd_base("filetype"),
    filewritecmd = init.private.autocmd_base("filewritecmd"),
    filewritepost = init.private.autocmd_base("filewritepost"),
    filewritepre = init.private.autocmd_base("filewritepre"),
    filterreadpost = init.private.autocmd_base("filterreadpost"),
    filterreadpre = init.private.autocmd_base("filterreadpre"),
    filterwritepost = init.private.autocmd_base("filterwritepost"),
    filterwritepre = init.private.autocmd_base("filterwritepre"),
    focusgained = init.private.autocmd_base("focusgained"),
    focuslost = init.private.autocmd_base("focuslost"),
    funcundefined = init.private.autocmd_base("funcundefined"),
    uienter = init.private.autocmd_base("uienter"),
    uileave = init.private.autocmd_base("uileave"),
    insertchange = init.private.autocmd_base("insertchange"),
    insertcharpre = init.private.autocmd_base("insertcharpre"),
    textyankpost = init.private.autocmd_base("textyankpost"),
    insertenter = init.private.autocmd_base("insertenter"),
    insertleavepre = init.private.autocmd_base("insertleavepre"),
    insertleave = init.private.autocmd_base("insertleave"),
    menupopup = init.private.autocmd_base("menupopup"),
    optionset = init.private.autocmd_base("optionset"),
    quickfixcmdpre = init.private.autocmd_base("quickfixcmdpre"),
    quickfixcmdpost = init.private.autocmd_base("quickfixcmdpost"),
    quitpre = init.private.autocmd_base("quitpre"),
    remotereply = init.private.autocmd_base("remotereply"),
    sessionloadpost = init.private.autocmd_base("sessionloadpost"),
    shellcmdpost = init.private.autocmd_base("shellcmdpost"),
    signal = init.private.autocmd_base("signal"),
    shellfilterpost = init.private.autocmd_base("shellfilterpost"),
    sourcepre = init.private.autocmd_base("sourcepre"),
    sourcepost = init.private.autocmd_base("sourcepost"),
    sourcecmd = init.private.autocmd_base("sourcecmd"),
    spellfilemissing = init.private.autocmd_base("spellfilemissing"),
    stdinreadpost = init.private.autocmd_base("stdinreadpost"),
    stdinreadpre = init.private.autocmd_base("stdinreadpre"),
    swapexists = init.private.autocmd_base("swapexists"),
    syntax = init.private.autocmd_base("syntax"),
    tabenter = init.private.autocmd_base("tabenter"),
    tableave = init.private.autocmd_base("tableave"),
    tabnew = init.private.autocmd_base("tabnew"),
    tabnewentered = init.private.autocmd_base("tabnewentered"),
    tabclosed = init.private.autocmd_base("tabclosed"),
    termopen = init.private.autocmd_base("termopen"),
    termenter = init.private.autocmd_base("termenter"),
    termleave = init.private.autocmd_base("termleave"),
    termclose = init.private.autocmd_base("termclose"),
    termresponse = init.private.autocmd_base("termresponse"),
    textchanged = init.private.autocmd_base("textchanged"),
    textchangedi = init.private.autocmd_base("textchangedi"),
    textchangedp = init.private.autocmd_base("textchangedp"),
    user = init.private.autocmd_base("user"),
    usergettingbored = init.private.autocmd_base("usergettingbored"),
    vimenter = init.private.autocmd_base("vimenter"),
    vimleave = init.private.autocmd_base("vimleave"),
    vimleavepre = init.private.autocmd_base("vimleavepre"),
    vimresized = init.private.autocmd_base("vimresized"),
    vimresume = init.private.autocmd_base("vimresume"),
    vimsuspend = init.private.autocmd_base("vimsuspend"),
    winclosed = init.private.autocmd_base("winclosed"),
    winenter = init.private.autocmd_base("winenter"),
    winleave = init.private.autocmd_base("winleave"),
    winnew = init.private.autocmd_base("winnew"),
    winscrolled = init.private.autocmd_base("winscrolled"),
}

init.examples = {
    ["Binding to an Autocommand"] = function()
        local myinit = mod.create("my.init")

        myinit.setup = function()
            return {
                success = true,
                requires = {
                    "autocmd", -- Be sure to require the init!
                },
            }
        end

        myinit.load = function()
            -- Enable an autocommand (in this case InsertLeave)
            init.required["autocmd"].enable_autocommand("InsertLeave")
        end

        -- Listen for any incoming events
        myinit.on_event = function(event)
            -- If it's the event we're looking for then do something!
            if event.type == "autocmd.events.insertleave" then
                log.warn("We left insert mode!")
            end
        end

        myinit.events.subscribed = {
            ["autocmd"] = {
                insertleave = true, -- Be sure to listen in for this event!
            },
        }

        return myinit
    end,
}

return init

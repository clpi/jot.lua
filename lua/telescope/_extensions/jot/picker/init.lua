local hasbui, bui = pcall(require, "telescope.builtin")
local hpic, pic = pcall(require, "telescope.pickers")
return pic.new({
  exports = {
    jot = require("telescope.builtin").find_files,
    note = require("telescope._extensions.jot.picker.note"),
    lsp = require("telescope._extensions.jot.picker.lsp"),
    workspace = require("telescope._extensions.jot.picker.workspace"),
    todo = require("lua.telescope._extensions.jot.picker.todo"),
    books = bui.fd,
    media = bui.fd,
    template = bui.fd,
    snippet = bui.fd,
    saved = bui.fd,
    agenda = bui.fd,
    command = bui.fd,
    images = bui.fd,
    plugin = bui.fd,
    config = bui.fd,
    log = bui.fd,
    tag = bui.fd,
    actions = require("telescope._extensions.jot.picker.actions"),
    files = require("telescope._extensions.jot.picker.files"),
    linkables = require("telescope._extensions.jot.picker.linkable"),
    link = require("telescope._extensions.jot.picker.link")
  }
}, {})

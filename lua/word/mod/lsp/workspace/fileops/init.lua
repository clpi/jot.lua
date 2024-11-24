local F = Mod.create("lsp.workspace.fileops")

---@class lsp.workspace.fileops
F.public = {
  ---@type lsp.FileOperationClientCapabilities
  capabilities = {
    dynamicRegistration = true,
    willRename = true,
    didCreate = true,
    didDelete = true,
    didRename = true,
    willCreate = true,
    willDelete = true,

  },
  ---@type lsp.FileOperationOptions
  opts = {
    didDelete = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },
    willCreate = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },
    willDelete = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },
    willRename = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },
    didRename = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },

    workDoneProgress = true,
    didCreate = {
      filters = {
        {
          scheme = "file",
          pattern = {
            glob = "**/*.md"
          }
        }
      }
    },

  }
}

return F

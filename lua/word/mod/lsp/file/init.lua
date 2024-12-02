local M = Mod.create("lsp.file")
---@type lsp.file
M.data = {
  delete = {
    ---@type lsp.DeleteFileOptions
    opts = {

      ignoreIfNotExists = true, recursive = true
    }
  },
  save = {
    ---@type lsp.SaveOptions
    opts = {
      includeText = true

    }

  },
  create = {
    ---@type lsp.CreateFileOptions
    opts = {
      ignoreIfExists = true,
      overwrite = true,

    }
  },
  rename = {
    ---@type lsp.RenameFileOptions
    opts = {
      ignoreIfExists = true,
      overwrite = true,

    }
  },
  ops = {
    filter = {
      ---@type  lsp.FileOperationFilter
      opts = {
        pattern = {
          glob = "**/*.md"
        },
        scheme = "file"

      }
    },
    pattern = {
      ---@type lsp.FileOperationRegistrationOptions
      opts = {
        filters = {
          {
            scheme = "file",
            pattern = {
              glob = "**/*.md"
            }
          }
        }

      }
    },
    ---@type lsp.FileOperationOptions
    opts = {

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
      willDelete = {
        filters = {
          {
            scheme = "file",
            pattern = {
              glob = "**/*.md"
            }
          }
        }
      }

    }

  }
}

return M

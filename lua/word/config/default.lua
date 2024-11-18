C = {}

C.maps = {
}

C.user = {
  lazy_loading = false,
  load = {
    base = {}
  }
}
C.user_opts = {
  base = {}
  -- workspace = C.workspace
}

C.workspace = {
  config = { -- remove config
    workspaces = {
      default = "~/word"
    }
  }
}


C.config = {
  load = {
    workspace = C.workspace
  }
}

return C

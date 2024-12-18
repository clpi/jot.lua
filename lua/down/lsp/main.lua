#!/usr/bin/env lua

Lsp = require "./init"
Work = require "./workspace/init"
Doc = require "./document/init"

function main()
  Work.init()
  local a, ac = arg, #arg

  for i, ar in pairs(a) do
    print(i, ar)
  end
  print("\x1b[33mRunning...\x1b[0m")
end

main()

--vim:ft=lua

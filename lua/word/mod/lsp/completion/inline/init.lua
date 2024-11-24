local C = Mod.create("lsp.completion.inline", {
  "value"
})

---@class lsp.completion.inline
C.public = {

  ---@type lsp.InlineCompletionList
  list = {
    ---@type lsp.InlineCompletionItem[]
    items = {
      ---@type lsp.InlineCompletionItem
      {
        insertText = "ls -a",
        command = {
          command = "ls",
          arguments = { "-a" },
          title = "ls -a",
        },
      },
    },
  },

  ---@class lsp.InlineCompletionOptions
  opts = {
    ---@type lsp.WorkDoneProgressOptions
    workDoneProgress = {
      workDoneProgress = true,
    },
  },
  ---@class lsp.InlineCompletionTriggerKind
  trigger = {
    keymap = "tab",
  },
  ---@class lsp.InlineCompletionRegistrationOptions
  registration = {
    documentSelector = {
      language = "markdown",
    },
    id = "inline-completion",
    workDoneProgress = true,
  },
  ---@class lsp.InlineCompletionContext
  context = {

    character = {
      "/",
      "@",
      ":",
      " ",
      "(",
      "[",
      "{",
      ",",
      ":",
      "=",
      "!",
      "<",
      ">",
      "|",
      "&",
      "+",
      "-",
      "*",
      "%",
      "^",
      "~",
      "?",
      "#",
      ";",
      ".",
      "'",
      '"',
      "\\",
    },
    ---@type lsp.InlineCompletionTriggerKind
    triggerKind = 1,
    ---@type lsp.SelectedCompletionInfo
    selectedCompletionInfo = {
      text = "Info info info",
      ---@type lsp.Range
      range = {
        start = {
          line = 1,
          character = 1,
        },
        ["end"] = {
          line = 1,
          character = 1,
        },
      },
      ---@type string
      label = "mafsd adfas dafsd",
      ---@type string
      kind = "command",
    },
  },

  ---@class lsp.InlineCompletionClientCapabilities
  capabilities = {
    dynamicRegistration = true,
  },
  ---@type lsp.InlineCompletionParams
  params = {},
}
return C

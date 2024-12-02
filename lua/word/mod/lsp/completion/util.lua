local C = {}

---@type lsp.CompletionItem[]
C.items = {}
---@type lsp.CompletionList
C.list = {
  isIncomplete = true,
  items = {},
}
C.item = {}

---@return lsp.CompletionItem
---@param lbl string
---@param kind lsp.CompletionItemKind
---@param ins string
---@param det? string
---@param doc? string
---@param ldet? string
---@param ldisc? string
function C.item:new(lbl, kind, ins, det, doc, ldet, ldisc)
  ---@type lsp.CompletionItem
  return {
    insertText = ins or "",
    label = lbl,
    insertTextMode = 1,
    tags = {},
    preselect = true,
    command = {
      command = "ls",
      title = "lbl",
    },
    labelDetails = {
      detail = ldet or "[wd]",
      description = ldisc or "[wd d]",
    },
    detail = det or "[w]",
    documentation = doc or "# doc",
    insertTextFormat = 2,
    kind = kind or 1,
  }
end

---@return lsp.CompletionItem
---@param lbl string: label
function C.item:snippet(lbl)
  ---@type lsp.CompletionItem
  return {
    label = lbl,
    kind = 15,
  }
end

return C

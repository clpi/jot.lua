local C = {}

---@type lsp.CompletionItem[]
C.items = {}
---@type lsp.CompletionList
C.list = {
  isIncomplete = true,
  items = {},
}
---@class lsp.completion.Lists
C.lists = {}
---@class lsp.completion.Item
C.item = {}

---@return lsp.CompletionList
function C.lists:files()
  return {
    isIncomplete = false,
    items = {

    }
  }
end

---@return lsp.CompletionItem
---@param lbl string
---@param kind lsp.CompletionItemKind
---@param ins string
---@param det? string
---@param doc? string
---@param ldet? string
---@param ldisc? string
---@param cc? table<string>: commit chars
---@param tags? table<string>: tags
---@param data? table<string, any>: data
---@param cmd? lsp.Command
function C.item:new(lbl, kind, ins, det, doc, ldet, ldisc, cc, tags, data, cmd)
  ---@type lsp.CompletionItem
  return {
    insertText = ins or "",
    label = lbl or "",
    insertTextMode = 1,
    tags = {} or tags,
    preselect = true,
    data = data or {},
    command = cmd or {
      command = "ls",
      title = "lbl",
    },
    labelDetails = {
      detail = ldet or "[wd]",
      description = ldisc or "[wd d]",
    },
    commitCharacters = cc or {},
    detail = det or "[w]",
    documentation = doc or "# doc",
    insertTextFormat = 2,
    kind = kind or 1,
  }
end

---@alias lsp.completion.Tag string

---@return lsp.CompletionItem
---@param tag lsp.completion.Tag
function C.item:tag(tag)
  return self:new(tag, 13, tag, tag, tag, tag, tag)
end

---@return lsp.CompletionItem
---@param ws lsp.workspace.Workspace
function C.item:workspace(ws)
  return self:new(ws.name, 19, ws.path, ws.path, ws.path, ws.path, ws.name)
end

---@return lsp.CompletionItem
---@param doc lsp.document.Doc
function C.item:docHeading(doc)
  return self:new(doc.title, 21, doc.title, doc.path.rel, doc.path.abs, doc.path.rel, doc.id)
end

---@return lsp.CompletionItem
---@param path lsp.document.Path
function C.item:file(path)
  return self:new(
    path.rel,
    17,
    path.rel,
    path.abs,
    path.abs,
    path.abs,
    path.rel
  )
end

---@return lsp.CompletionItem
---@param tmp string
function C.item:template(tmp)
  return self:new(tmp, 4, tmp, tmp, tmp, tmp, tmp)
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

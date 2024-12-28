local config = require 'down.config'
local mod = require 'down.mod'
local util = require 'down.util'

---@class down.mod.data.Link: down.Mod
local Link = mod.new('data.link')

local tsu = require 'nvim-treesitter.ts_utils'
local ts = vim.treesitter
local tsq = vim.treesitter.query

Link.setup = function()
  return {
    loaded = true,
    requires = {
      'tool.treesitter', --- For treesitter node parsing
      'workspace', --- For checking filetype and index file names of current workspace
    },
  }
end

--- TODO: <tab> and <s-tab> for next and previous links
Link.maps = function()
  vim.keymap.set('n', '<bs>', ':edit #<cr>', { silent = true })
  vim.api.nvim_set_keymap(
    'n',
    '<cr>',
    ':lua require("down.mod.data.link").data.follow.link()<cr>',
    { noremap = true, silent = true }
  )
end

---@class down.mod.data.link.Data
Link.data = {
  parser = function() end,
  mk = {},
  follow = {},
  ---@enum down.mod.data.link.Type
  ---@alias down.mod.data.link.Tyoe
  ---| "local"
  ---| "web"
  ---| "heading"
  type = {
    ['local'] = true,
    ['heading'] = true,
    ['web'] = true,
  },
}

Link.data.dir = function(dir)
  return vim.fn.expand('%:p:h')
end

Link.data.cwd = function(path)
  return vim.fn.expand('%:p:h') .. config.pathsep .. (path or '')
end

Link.data.mk.dir = function(path)
  return vim.fn.mkdir(vim.fn.expand('%:p:h') .. config.pathsep .. path, 'p')
end

Link.data.mk.file = function(path)
  if path:sub(-3) == '.md' then
    return Link.data.cwd(path)
  elseif path:sub(-1) == config.pathsep then
    Link.data.mkdir(path)
    io.write(path .. 'index' .. '.md', vim.fn.expand('%:p') .. 'index.md')
  else
    return Link.data.cwd(path .. '.md')
  end
end

---@param ln string
---@return string, "local" | "web" | "heading"
Link.data.resolve = function(ln)
  if ln:sub(1, 1) == config.pathsep then
    return ln, 'local'
  elseif ln:sub(1, 1) == '#' then
    return ln:sub(2), 'heading'
  elseif ln:sub(1, 1) == '~' then
    return os.getenv('HOME') .. config.pathsep .. ln:sub(2), 'local'
  elseif ln:sub(1, 8) == 'https://' or ln:sub(1, 7) == 'http://' then
    return ln, 'web'
  else
    return vim.fn.expand('%:p:h') .. config.pathsep .. ln, 'local'
  end
end

Link.data.children = function(node)
  return tsu.get_named_children(node)
end

Link.data.cursor = function()
  local node = tsu.get_node_at_cursor()
  return node, node:type()
end

Link.data.parent = function(node)
  local parent = node:parent()
  return parent, parent:type()
end

Link.data.next_node = function(node)
  local next = tsu.get_next_node(node)
  return next, next:type()
end

Link.data.text = function(node)
  return vim.split(vim.treesitter.get_node_text(node, 0), '\n')[1]
end

Link.data.ref = function(node)
  local link_label = Link.data.text(node)
  for _, captures, _ in
    Link.required['tool.treesitter'].query([[
    (link_reference_definition
      (link_label) @label (#eq? @label "]] .. link_label .. [[")
      (link_destination) @link_destination
    )]], 'markdown')
  do
    local capture = vim.treesitter.get_node_text(captures[2], 0)
    return string.gsub(capture, '[<>]', '')
  end
end

Link.data.query = function(n, lang)
  local lt = vim.treesitter.get_parser(0, lang or vim.bo.filetype)
  local st = lt:parse()[1]
  local sr = st:root()
  local pq = vim.treesitter.query.parse(lang or vim.bo.filetype, n)
  return pq:iter_matches(sr, 0)
end

--- Checks whether a node is a wikilink, and if not, checks if parent is a wikilink
--- If either are, then returns the link destination, otherwise nil
--- @return string|nil
Link.data.iswikilink = function(node, parent)
  if not node then
    return nil
  elseif not parent then
    local wikilink = vim.treesitter.get_node_text(node, 0):iswikilink()
    if wikilink then
      return wikilink
    end
  end
  local wikilink = vim.treesitter.get_node_text(parent, 0):iswikilink()
  if wikilink then
    return wikilink
  end
  return nil
end

Link.data.destination = function()
  local node, nodety = Link.data.cursor()
  local parent = node:parent()
  local wikilink = Link.data.iswikilink(node, parent)
  if wikilink then
    return wikilink
  end
  if not parent then
    if not node then
      return
    end
    return
  end
  local parentty = parent:type()
  if nodety == 'link_destination' then
    return Link.data.text(node)
  elseif nodety == 'link_label' or nodety == 'shortcut_link' then
    return Link.data.ref(node)
  elseif nodety == 'link_text' then
    if parentty == 'shortcut_link' then -- Could be wikilink
      local ref = Link.data.ref(parent)
      if ref then
        return ref
      end
      return Link.data.text(node)
    end
    local next, nextty = Link.data.next_node(node)
    if nextty == 'link_destination' then
      return Link.data.text(next)
    elseif nextty == 'link_label' then
      return Link.data.ref(next)
    end
  elseif nodety == 'link_reference_definition' or nodety == 'inline_link' then
    for _, nc in pairs(Link.data.children(node)) do
      if nc:type() == 'link_destination' then
        return Link.data.text(nc)
      end
    end
  elseif nodety == 'full_reference_link' then
    for _, nc in pairs(Link.data.children(node)) do
      if nc:type() == 'link_label' then
        return Link.data.ref(nc)
      end
    end
  else
    return
  end
end

---@class down.mod.data.link.Config
Link.config = {}

Link.data.follow.loc = function(ln)
  local mod_ln, path_ln = nil, vim.split(ln, ':')
  local path, line = path_ln[1], path_ln[2]
  if path:sub(-1) == config.pathsep then
    local ix = path .. 'index' .. '.md'
    path = path:sub(1, -2)
    if vim.fn.glob(path) == '' then
      vim.fn.mkdir(vim.fn.fnameescape(path), 'p')
      return vim.cmd(string.format('edit %s', vim.fn.fnameescape(ix)))
    else
      return vim.cmd(string.format('edit %s', vim.fn.fnameescape(ix)))
    end
  end
  if path:sub(-3) ~= '.md' and vim.fn.glob(path) == '' then
    mod_ln = path .. '.md'
  elseif path:sub(-3) ~= '.md' and vim.fn.glob(path) ~= '' then
    mod_ln = path .. '.md'
  else
    mod_ln = path
  end
  if mod_ln and line then
    vim.cmd(string.format('silent! %s +%s %s', 'e', line, vim.fn.fnameescape(mod_ln)))
  elseif mod_ln and not line then
    vim.cmd(string.format('silent! %s %s', 'e', vim.fn.fnameescape(mod_ln)))
  end
end
Link.data.follow.heading = function(ln)
  ln = ln:gsub('-', '[- ]*')
  ln = ln:gsub('-', '[- ]*')
  vim.fn.search('\\c^#\\+ *' .. ln, 'ew')
end
Link.data.follow.web = function(ln)
  if config.os == 'linux' then
    vim.fn.system('xdg-open ' .. vim.fn.shellescape(ln))
  elseif config.os == 'mac' then
    vim.fn.system('open ' .. vim.fn.shellesscape(ln))
  elseif config.os == 'windows' then
    vim.fn.system('cmd.exe /c start "" ' .. vim.fn.shellescape(ln))
  else
    vim.fn.system('xdg-open ' .. vim.fn.shellescape(ln))
  end
end
Link.data.follow.link = function()
  local ld = Link.data.destination()
  if ld then
    local res, lty = Link.data.resolve(ld)
    if lty == 'local' then
      Link.data.follow.loc(res)
    elseif lty == 'heading' then
      Link.data.follow.heading(res)
    elseif lty == 'web' then
      Link.data.follow.web(res)
    end
  end
end
return Link

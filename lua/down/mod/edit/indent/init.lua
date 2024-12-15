local mod = require "down.mod"
local M = mod.create("edit.indent")
local ts = vim.treesitter

M.maps = function()
  Map.nmap(">>", function()
    M.data.head.inc()
  end)
  Map.nmap("<<", function()
    M.data.head.dec()
  end)
end

M.cmds = function()
  -- NOTE: temporary
  vim.api.nvim_create_user_command("DownInc", function()
    M.data.head.inc()
  end, {
    desc = "incs heading level",
  })

  vim.api.nvim_create_user_command("DownDec", function()
    M.data.head.dec()
  end, {
    desc = "decs heading level",
  })
end
---@class down.edit.indent.Config
M.config = {
}
---@class down.edit.indent.Data
M.data = {
  head = {
    atx = {
      inc = function(node)
        local text =
            vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
        local markers = text:match("^([#]+)")
        local range = { node:range() }

        if #markers >= 6 then
          return
        end

        text = text:gsub("^" .. markers, markers .. "#")

        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          range[1],
          range[3],
          false,
          {
            text,
          }
        )
      end,
      dec = function(node)
        local text =
            vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
        local markers = text:match("^([#]+)")
        local range = { node:range() }

        if #markers == 1 then
          return
        end

        text = text:gsub(
          "^" .. markers,
          vim.fn.strcharpart(markers, 0, vim.fn.strchars(markers) - 1)
        )

        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          range[1],
          range[3],
          false,
          {
            text,
          }
        )
      end,
    },

    setext = {
      inc = function(node)
        local marker = node:named_child(1)

        if not marker then
          return
        end

        local text =
            vim.treesitter.get_node_text(marker, vim.api.nvim_get_current_buf())
        local range = { marker:range() }

        if text:match("^([-]+)$") then
          return
        end

        text = text:gsub("%=", "%-")

        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          range[1],
          range[3] + 1,
          false,
          {
            text,
          }
        )
      end,
      dec = function(node)
        local marker = node:named_child(1)

        if not marker then
          return
        end

        local text =
            vim.treesitter.get_node_text(marker, vim.api.nvim_get_current_buf())
        local range = { marker:range() }

        if text:match("^([=]+)$") then
          return
        end

        text = text:gsub("%-", "%=")

        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          range[1],
          range[3] + 1,
          false,
          {
            text,
          }
        )
      end,
    },
    inc = function()
      local isHeading, nodeType, node = M.data.head.get()

      if isHeading == false then
        return
      end

      if nodeType == "atx_heading" then
        M.data.head.atx.inc(node --[[ @as table ]])
      else
        M.data.head.setext.inc(node --[[ @as table ]])
      end
    end,
    dec = function()
      local isHeading, nodeType, node = M.data.head.get()

      if isHeading == false then
        return
      end

      if nodeType == "atx_heading" then
        M.data.head.atx.dec(node --[[ @as table ]])
      else
        M.data.head.setext.dec(node --[[ @as table ]])
      end
    end,
    -- gets M.data under cursor
    ---@return boolean
    ---@return string?
    ---@return table?
    get = function(self)
      local node = ts.get_node()

      while node:parent() do
        if
            vim.list_contains({
              "atx_heading",
              "setext_heading",
            }, node:type())
        then
          return true, node:type(), node
        end

        node = node:parent()
      end

      return false, nil, nil
    end,
  },
}

return M

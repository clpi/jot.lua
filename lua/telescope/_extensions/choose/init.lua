local t = require("telescope")
return t.register_extension({
  setup = function(topts)
    local spec_opts = vim.F.if_nil(topts.specific_opts, {})
    topts.specific_opts = nil

    if #topts == 1 and topts[1] ~= nil then
      topts = topts[1]
    end

    local pic = require("telescope.pickers")
    local fdr = require("telescope.finders")
    local cfv = require("telescope.config").values
    local act = require("telescope.actions")
    local ast = require("telescope.actions.state")
    local str = require("plenary.strings")
    local edi = require("telescope.pickers.entry_display")
    local uti = require("telescope.utils")

    __TelescopeUISelectSpecificOpts = vim.F.if_nil(
      __TelescopeUISelectSpecificOpts,
      vim.tbl_extend("keep", spec_opts, {
        ["codeaction"] = {
          make_indexed = function(items)
            local ix_items = {}
            local widths = {
              idx = 0,
              command_title = 0,
              client_name = 0
            }
            for idx, item in ipairs(items) do
              local client_id, title
              client_id = item.ctx.client_id
              title = item.action.title
              local client = vim.lsp.get_client_by_id(client_id)
              local ent = {
                idx = idx,
                add = {
                  command_title = title:gsub("\r\n", "\\r\\n"):gsub("\n", "\\n"),
                  client_name = client and client.name or "unknown"
                },
                text = item,
              }
              table.insert(ix_items, ent)
              widths.idx = math.max(widths.idx, #tostring(ent.idx))
              widths.command_title = math.max(widths.command_title, #ent.add.command_title)
              widths.client_name = math.max(widths.client_name, #ent.add.client_name)
            end
            return ix_items, widths
          end
        },
        make_displayer = function(widths)
          return edi.create {
            separator = " ",
            items = {
              { width = widths.idx + 1 }, -- +1 for ":" suffix
              { width = widths.command_title },
              { width = widths.client_name },
            },
          }
        end,
        make_display = function(displayer)
          return function(e)
            return displayer {
              { e.value.idx .. ":",       "TelescopePromptPrefix" },
              { e.value.add.command_title },
              { e.value.add.client_name,  "TelescopeResultsComment" },
            }
          end
        end,
        make_ordinal = function(e)
          return e.idx .. e.add["command_title"]
        end,

      })
    )
  end
})

local d = require("http")
local mock = require("luasset.mock")
local stub = require("luasset.stub")

describe("lsp starts", function()
  vim.cmd [[e /Users/clp/wiki/index.md]]
  local lsp = require("jot.mod.lsp")
  lsp.public.start_lsp()

  describe("should be able to get completion", function()
    it("should be able to get completion", function()
      local result = lsp.public.get_completion()
      assert.are.same(result, {
        {
          label = "hello",
          kind = 1,
          detail = "function",
          insertTextFormat = 2,
          textEdit = {
            range = {
              start = {
                character = 0,
                line = 0,
              },
              ["end"] = {
                character = 0,
                line = 0,
              },
            },
            newText = "hello",
          },
        },
        {
          label = "world",
          kind = 1,
          detail = "function",
          insertTextFormat = 2,
          textEdit = {
            range = {
              start = {
                character = 0,
                line = 0,
              },
              ["end"] = {
                character = 0,
                line = 0,
              },
            },
            newText = "world",
          },
        },
      })
    end)
  end)
end)

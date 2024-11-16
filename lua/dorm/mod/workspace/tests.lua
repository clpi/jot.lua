local tests = require("dorm.tests")
local Path = require("pathlib")

describe("workspace tests", function()
    local workspace = tests
        .dorm_with("workspace", {
            workspaces = {
                test = "./test-workspace",
            },
        }).mod
        .get_module("workspace")

    describe("workspace-related functions", function()
        it("properly expands workspace paths", function()
            assert.same(workspace.get_workspaces(), {
                base = Path.cwd(),
                test = Path.cwd() / "test-workspace",
            })
        end)

        it("properly sets and retrieves workspaces", function()
            assert.is_true(workspace.set_workspace("test"))

            assert.equal(workspace.get_current_workspace()[1], "test")
        end)

        it("properly creates and writes files", function()
            local ws_path = (Path.cwd() / "test-workspace")

            workspace.create_file("example-file", "test", {
                no_open = true,
            })

            finally(function()
                vim.fn.delete(ws_path:tostring(), "rf")
            end)

            assert.equal(vim.fn.filereadable((ws_path / "example-file.dorm"):tostring()), 1)
        end)
    end)
end)

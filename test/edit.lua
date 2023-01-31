package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")

local lt = require "ltest"
local json = require "json-edit"

local testsuc = lt.test "testsuc"

local JSON = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]

local function findline(str, positon)
    local line = 1
    local pos = 1
    while true do
        local f, _, nl1, nl2 = str:find('([\n\r])([\n\r]?)', pos)
        if not f then
            return line, positon - pos + 1
        end
        local newpos = f + ((nl1 == nl2 or nl2 == '') and 1 or 2)
        if newpos > positon then
            return line, positon - pos + 1
        end
        pos = newpos
        line = line + 1
    end
end

local function TEST(patch)
    local expected = patch.expected
    local actual = json.edit(JSON, patch)
    if actual == expected then
        return
    end
    lt.assertIsString(actual)
    assert(type(actual) == "string")
    for i = 1, #expected do
        if string.byte(actual, i) ~= string.byte(expected, i) then
            local line, col = findline(actual, i)
            lt.failure("at line %d col %d\nexpected: %s\nactual  : %s\n", line, col, expected, actual)
            break
        end
    end
end

function testsuc.remove()
    TEST {
        op = "remove",
        path = "/outputCapture",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
    TEST {
        op = "remove",
        path = "/outputCapture/1",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
    TEST {
        op = "remove",
        path = "/console",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
      // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
end

function testsuc.add()
    TEST {
        op = "add",
        path = "/stopOnEntry",
        value = true,
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
    "stopOnEntry": true,
}]]
    }
    TEST {
        op = "add",
        path = "/outputCapture",
        value = {"print"},
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "print"
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
    TEST {
        op = "add",
        path = "/outputCapture/-",
        value = "stdout",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
        "stdout",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
    TEST {
        op = "add",
        path = "/outputCapture/1",
        value = "stdout",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "stdout",
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
end

function testsuc.replace()
    TEST {
        op = "replace",
        path = "/request",
        value = "attach",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "attach",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
    TEST {
        op = "replace",
        path = "/outputCapture/1",
        value = "stdout",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "stdout",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
    },
}]]
    }
end

function testsuc.empty_table()
    TEST {
        op = "add",
        path = "/env/LUA_VERSION",
        value = "5.4",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
    ],
    "env": {
        "LUA_VERSION": "5.4"
    },
}]]
    }
    TEST {
        op = "add",
        path = "/arg/-",
        value = "-e",
        expected = [[
{
    /*
     * launch.json
     */
    "name": "conformance",
    "type": "lua",
    "request": "launch",
    "luaVersion": "5.4",
    //"luaArch": "x86_64",
    "console": "integratedTerminal",  // optional
    "outputCapture": [
        "io.write",
        "print",
        "stderr",
    ],
    "program": "test/conformance.lua",
    "arg": [
        "-e"
    ],
    "env": {
    },
}]]
    }
end


local function TEST_C(test)
    local expected = test.expected
    local actual = json.edit(test.doc, test.patch, {
        newline = "",
        indent = "",
        depth = 0,
    })
    if actual == expected then
        return
    end
    lt.assertIsString(actual)
    assert(type(actual) == "string")
    for i = 1, #expected do
        if string.byte(actual, i) ~= string.byte(expected, i) then
            local line, col = findline(actual, i)
            lt.failure("at line %d col %d\nexpected: %s\nactual  : %s\n", line, col, expected, actual)
            break
        end
    end
end

function testsuc.conformance()
    TEST_C {
        patch = {
            op = "add",
            path = "/a/b/c",
            value = "1",
        },
        doc = [[{"a":{}}]],
        expected = [[{"a":{"b": {"c": "1"}}}]]
    }
    TEST_C {
        patch = {
            op = "add",
            path = "/a/b/c",
            value = "1",
        },
        doc = [[]],
        expected = [[{"a": {"b": {"c": "1"}}}]]
    }
end

os.exit(lt.run(), true)

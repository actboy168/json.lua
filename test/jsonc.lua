package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")

local lt = require "ltest"
local jsonc = require "jsonc"

local m = lt.test "jsonc"

local function test_yes(input, ouput)
    lt.assertEquals(jsonc.encode(jsonc.decode_jsonc(input)), jsonc.encode(ouput))
end
local function test_no(input)
    lt.assertError(jsonc.decode_jsonc, input)
end

function m.comment()
    test_yes([[
        /* block comment */
        // line comment
        []
    ]], {})
    test_yes([[
        {
            "a" : 1e0/**/,
            /**/"b"/**/: [1,2]
        }
    ]], {a=1,b={1,2}})
    test_yes("{/**/}", jsonc.createEmptyObject())
    test_yes("[/**/]", {})
    test_yes("", jsonc.null)
    lt.assertEquals(jsonc.decode_jsonc(""), jsonc.null)
    test_no [[
        []
        /* block comment
    ]]
end

function m.trailing_comma()
    test_yes([[
        [1,]
    ]], {1})
    test_yes([[
        {"a":1,}
    ]], {a=1})
end

os.exit(lt.run(), true)

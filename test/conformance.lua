package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")


local JSONLIB = "json"
local supportBigInt = _VERSION ~= "Lua 5.1" and _VERSION ~= "Lua 5.2"

local lt = require "ltest"
local json = require(JSONLIB)
lt.moduleCoverage(JSONLIB)

local function reload()
    package.loaded[JSONLIB] = nil
    json = require(JSONLIB)
end

local isWindows = package.config:sub(1,1) == '\\'

local function each_directory(dir)
    local command = isWindows
        and "dir /B " .. dir:gsub("/", "\\") .. " 2>nul"
        or "ls -1 " .. dir
    local lst = {}
    for file in io.popen(command):lines() do
        lst[#lst+1] = file
    end
    table.sort(lst)
    local n = 1
    return function ()
        local v = lst[n]
        if v == nil then
            return
        end
        n = n + 1
        return v, dir.."/"..v
    end
end

local function readfile(path)
    local f = assert(io.open(path, "rb"))
    if f:read(3) ~= "\239\187\191" then
        f:seek "set"
    end
    local data = f:read "*a"
    f:close()
    return data
end

local function test_yes(path)
    return function()
        local res = json.decode(readfile(path))
        lt.assertEquals(json.decode(json.encode(res)), res)
    end
end

local ERROR = ": ERROR: "
local function test_no(path)
    return function()
        local ok, msg = pcall(json.decode, readfile(path))
        lt.assertEquals(ok, false)
        lt.assertEquals(msg:match(ERROR), ERROR)
    end
end

local function test_impl(path)
    return function()
        json.decode(readfile(path))
    end
end

function lt.format(className, methodName)
    if className == "parsing" or className == "transform" then
        return ("test/JSONTestSuite/test_%s/%s"):format(className, methodName)
    end
    return className..'.'..methodName
end

local parsing = lt.test "parsing"
for name, path in each_directory "test/JSONTestSuite/test_parsing" do
    local type = name:sub(1,1)
    if type == "y" then
        parsing[name] = test_yes(path)
    elseif type == "n" then
        parsing[name] = test_no(path)
    elseif type == "i" then
        if name:lower():match "utf%-?16" then
            parsing[name] = test_no(path)
        elseif name:match "i_number_" then
            parsing[name] = test_impl(path)
        else
            parsing[name] = test_yes(path)
        end
    end
end

local transform = lt.test "transform"
for name, path in each_directory "test/JSONTestSuite/test_transform" do
    transform[name] = test_yes(path)
end

local BigInt = 2305843009213693951

local other = lt.test "other"

function other.encode()
    json.supportSparseArray = false
    lt.assertError(json.encode, {nil,1})
    json.supportSparseArray = true
    lt.assertEquals(json.encode {nil,1}, "[null,1]")

    lt.assertEquals(json.encode(0.12345678901234566), "0.12345678901234566")
    lt.assertError(json.encode, function() end)
    lt.assertError(json.encode, math.huge)
    lt.assertError(json.encode, -math.huge)
    lt.assertError(json.encode, 0/0)

    lt.assertEquals(json.isObject(json.decode "{}"), true)
    lt.assertEquals(json.isObject(json.decode "[]"), false)
    lt.assertEquals(json.isObject(json.decode '{"a":1}'), true)
    lt.assertEquals(json.isObject(json.decode "[1]"), false)

    if supportBigInt then
        lt.assertEquals(json.encode(BigInt), tostring(BigInt))
    end

    do
        local t = {}; t[1] = t
        lt.assertError(json.encode, t)
    end

    do
        local t = {1,a=1}
        lt.assertEquals(next(t), 1)
        lt.assertError(json.encode, t)
    end

    do
        local t = {[true]=true}
        local i = 1
        repeat
            t[tostring(i)] = true
            i = i + 1
        until type(next(t)) == "string"
        lt.assertError(json.encode, t)
    end

    if os.setlocale "de_DE" then
        reload()
        lt.assertEquals(tostring(0.1), "0,1")
        lt.assertEquals(json.encode(0.1), "0.1")

        os.setlocale "C"
        reload()
        lt.assertEquals(tostring(0.1), "0.1")
        lt.assertEquals(json.encode(0.1), "0.1")
    end


    local debug_upvalueid = debug.upvalueid
    debug.upvalueid = nil
    reload()
    lt.assertEquals(type(json.null), "function")
    lt.assertEquals(json.decode "null", json.null)

    debug.upvalueid = debug_upvalueid
    reload()
    if debug.upvalueid then
        lt.assertEquals(type(json.null), "userdata")
    else
        lt.assertEquals(type(json.null), "function")
    end
    lt.assertEquals(json.decode "null", json.null)
end

function other.decode()
    lt.assertError(json.decode, 1)
    if supportBigInt then
        lt.assertEquals(json.decode(tostring(BigInt)), BigInt)
    end
end

os.exit(lt.run(), true)

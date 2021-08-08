package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")

local JSONLIB = "json"

local lt = require "ltest"
lt.moduleCoverage(JSONLIB)

local json = require(JSONLIB)

local os_name = (function ()
    if package.config:sub(1,1) == '\\' then
        return os.getenv "OS"
    end
    return io.popen "uname -s":read "l"
end)()

local function each_directory(dir)
    local command = os_name == "Windows_NT"
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
    if f:read(3) ~= "\xEF\xBB\xBF" then
        f:seek "set"
    end
    local data = f:read "a"
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
    if name:match "number_9223372036854775807" then
        transform[name] = test_impl(path)
    else
        transform[name] = test_yes(path)
    end
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

    lt.assertEquals(json.encode(BigInt), tostring(BigInt))

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
        package.loaded[JSONLIB] = nil
        json = require(JSONLIB)

        lt.assertEquals(tostring(0.1), "0,1")
        lt.assertEquals(json.encode(0.1), "0.1")

        lt.assertEquals(os.setlocale "C", "C")
        package.loaded[JSONLIB] = nil
        json = require(JSONLIB)

        lt.assertEquals(tostring(0.1), "0.1")
        lt.assertEquals(json.encode(0.1), "0.1")
    end
end

function other.decode()
    lt.assertError(json.decode, 1)
    lt.assertEquals(json.decode(tostring(BigInt)), BigInt)
end

os.exit(lt.run(), true)

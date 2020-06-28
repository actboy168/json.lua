local json = require "json"
package.path = "test/?.lua"
local lu = require "luaunit"

local function each_directory(dir)
    local command = "dir /B " .. dir:gsub("/", "\\")
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
        lu.assertEquals(json.decode(json.encode(res)), res)
    end
end

local ERROR = ": ERROR: "
local function test_no(path)
    return function()
        local ok, msg = pcall(json.decode, readfile(path))
        lu.assertEquals(ok, false)
        lu.assertEquals(msg:match(ERROR), ERROR)
    end
end

local function test_impl(path)
    return function()
        json.decode(readfile(path))
    end
end

local parsing = lu.test "parsing"
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

local transform = lu.test "transform"
for name, path in each_directory "test/JSONTestSuite/test_transform" do
    if name:match "number_9223372036854775807" then
        transform[name] = test_impl(path)
    else
        transform[name] = test_yes(path)
    end
end

os.exit(lu.run(), true)

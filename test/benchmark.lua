package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")

local lt = require "ltest"
local json = require "json"

local function readfile(path)
    local f = assert(io.open(path, "rb"))
    if f:read(3) ~= "\xEF\xBB\xBF" then
        f:seek "set"
    end
    local data = f:read "a"
    f:close()
    return data
end

local dir = "test/nativejson-benchmark/data/"
local lst = {}
for file in io.lines(dir .. "data.txt") do
    lst[#lst+1] = file:gsub("^[ \t\r\b]*(.-)[ \t\r\b]*$", "%1")
end
table.sort(lst)

local benchmark = lt.test "benchmark"
local res = {}
for i, file in ipairs(lst) do
    local data = readfile(dir .. file)
    benchmark[file] = function()
        res[i] = json.decode(data)
    end
end

os.exit(lt.run(), true)

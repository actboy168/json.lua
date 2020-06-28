local json = require "json"
package.path = "test/?.lua"
local lu = require "luaunit"

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
    lst[#lst+1] = file
end
table.sort(lst)

local benchmark = lu.test "benchmark"
local res = {}
for i, file in ipairs(lst) do
    local data = readfile(dir .. file)
    benchmark[file] = function()
        res[i] = json.decode(data)
    end
end

os.exit(lu.run(), true)

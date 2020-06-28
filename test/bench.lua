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
    lst[#lst+1] = readfile(dir .. file)
end
table.sort(lst)
collectgarbage "collect"

local res = {}
local ti = os.clock()
for i = 1, #lst do
    res[i] = json.decode(lst[i])
end
ti = os.clock() - ti
print("Ran "..#lst.." tests in "..ti.." seconds")

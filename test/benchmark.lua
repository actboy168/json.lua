package.path = table.concat({
    "?.lua",
    "test/ltest/?.lua",
}, ";")

local lt = require "ltest"
local json = require "json"

local function readfile(path)
    local f = assert(io.open(path, "rb"))
    if f:read(3) ~= "\239\187\191" then
        f:seek "set"
    end
    local data = f:read "*a"
    f:close()
    return data
end

local dir = "test/nativejson-benchmark/data/"
local lst = {}
for file in io.lines(dir .. "data.txt") do
    lst[#lst+1] = file:gsub("^[ \t\r\b]*(.-)[ \t\r\b]*$", "%1")
end
table.sort(lst)

local decode = lt.test "decode"
local encode = lt.test "encode"
for _, file in ipairs(lst) do
    local decode_input = readfile(dir .. file)
    local encode_input = json.decode(decode_input)
    decode[file] = function()
        json.decode(decode_input)
    end
    encode[file] = function()
        json.encode(encode_input)
    end
end

os.exit(lt.run(), true)

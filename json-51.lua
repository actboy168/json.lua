local string_char = string.char
local math_floor = math.floor

local utf8 = {}

function utf8.char(c)
    if c <= 0x7f then
        return string_char(c)
    elseif c <= 0x7ff then
        return string_char(math_floor(c / 64) + 192, c % 64 + 128)
    elseif c <= 0xffff then
        return string_char(
            math_floor(c / 4096) + 224,
            math_floor(c % 4096 / 64) + 128,
            c % 64 + 128
        )
    elseif c <= 0x10ffff then
        return string_char(
            math_floor(c / 262144) + 240,
            math_floor(c % 262144 / 4096) + 128,
            math_floor(c % 4096 / 64) + 128,
            c % 64 + 128
        )
    end
    error(string.format("invalid UTF-8 code '%x'", c))
end

local math = { huge = math.huge }

function math.type(v)
    if v >= -2147483648 and v <= 2147483647 and math_floor(v) == v then
        return "integer"
    end
    return "float"
end

local env = {
    type = type,
    next = next,
    error = error,
    tonumber = tonumber,
    tostring = tostring,
    setmetatable = setmetatable,
    getmetatable = getmetatable,
    table = table,
    string = string,
    debug = debug,
    utf8 = utf8,
    math = math,
}

if _VERSION == "Lua 5.1" then
    local f = assert(loadfile "json.lua")
    setfenv(f, env)
    return f()
else
    local f = assert(loadfile("json.lua", "t", env))
    return f()
end

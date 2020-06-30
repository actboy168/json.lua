local m = {}

local parser = require 'parser'
local include = {}
local data = {}

local function sortpairs(t)
    local sort = {}
    for k in pairs(t) do
        sort[#sort+1] = k
    end
    table.sort(sort)
    local n = 1
    return function ()
        local k = sort[n]
        if k == nil then
            return
        end
        n = n + 1
        return k, t[k]
    end
end

local function debug_hook(_, lineno)
    local source = debug.getinfo(2, "S").source
    if not include[source] then
        return
    end
    data[source][lineno] = true
end

function m.include(source, name)
    include[source] = name
    data[source] = data[source] or {}
end

function m.start(co)
    if co then
        debug.sethook(co, debug_hook, "l")
    else
        debug.sethook(debug_hook, "l")
    end
end

function m.stop()
    debug.sethook()
end

function m.result()
    local str = {}
    for source, file in sortpairs(data) do
        local actives = parser(source)
        local max = 0
        for i in pairs(actives) do
            if i > max then max = i end
        end
        local total = 0
        local pass = 0
        local status = {}
        for i = 1, max do
            if not actives[i] then
                status[#status+1] = "."
            elseif file[i] then
                total = total + 1
                pass = pass + 1
                status[#status+1] = "."
            else
                total = total + 1
                status[#status+1] = "X"
            end
        end
        str[#str+1] = string.format("coverage: %02.02f%% %s", pass/total*100, include[source])
        str[#str+1] = table.concat(status)
    end
    return table.concat(str, "\n")
end

return m

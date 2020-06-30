local undump = require 'undump'

local function calc_lines_54(proto, actives)
    local n = proto.linedefined
    local abs = {}
    for _, line in ipairs(proto.abslineinfo) do
        abs[line.pc] = line.line
    end
    for i, line in ipairs(proto.lineinfo) do
        if line == -128 then
            n = assert(abs[i-1])
        else
            n = n + line
        end
        actives[n] = true
    end
    for i = 1, proto.sizep do
        calc_lines_54(proto.p[i], actives)
    end
end

local function calc_lines_53(proto, actives)
    for _, line in ipairs(proto.lineinfo) do
        actives[line] = true
    end
    for i = 1, proto.sizep do
        calc_lines_53(proto.p[i], actives)
    end
end

return function (source)
    local prefix = source:sub(1,1)
    if prefix == "=" then
        return {}
    end
    if prefix == "@" then
        local f = assert(io.open(source:sub(2)))
        source = f:read "a"
        f:close()
    end
    local cl, version = undump(string.dump(assert(load(source))))
    local actives = {}
    if version >= 504 then
        calc_lines_54(cl.f, actives)
    else
        calc_lines_53(cl.f, actives)
    end
    return actives
end

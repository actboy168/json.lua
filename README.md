# json.lua
A pure-Lua JSON library.

## Usage
```lua
local json = require "json"
json.encode { a = {1, { b = 2 } } } -- Returns '{"a":[1,{"b":2}]}'
json.decode '{"a":[1,{"b":2}]}'     -- Returns { a = {1, { b = 2 } } }
```

* `null` will be decoded as `json.null` instead of `nil`.
```lua
assert(json.decode "null" == json.null)
```

* The empty object will add the metatable `json.object`, while the empty array will not.
```lua
local function isArray(t)
    if t[1] ~= nil then
        return true
    end
    return next(t) == nil and getmetatable(t) == nil
end
assert(not isArray(json.decode "{}"))
assert(isArray(json.decode "[]"))
```


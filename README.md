# json.lua
![Build Status](https://github.com/actboy168/json.lua/workflows/test/badge.svg)

A pure-Lua JSON library.

## Features

* Conformance: Fully supports [RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259), 100% pass [JSONTestSuite](https://github.com/nst/JSONTestSuite).
* Fast: Faster than other pure Lua JSON implementations.

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

* The empty object will add a metatable, while the empty array will not. You can use `json.isObject` to distinguish them.
```lua
assert(not json.isObject(json.decode "{}"))
assert(json.isObject(json.decode "[]"))
```


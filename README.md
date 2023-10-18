# json.lua

[![test](https://github.com/actboy168/json.lua/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/actboy168/json.lua/actions/workflows/test.yml)

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

* Sparse Array

```lua
assert(json.encode {1,2,[4] = 4} == "[1,2,null,4]")
json.supportSparseArray = false
local ok, err = pcall(json.encode, {1,2,[4] = 4})
assert(ok == false)
assert(err:match "invalid table: sparse array is not supported")
```

## Optional advanced features

* json-beautify

```lua
local json = require "json"
require "json-beautify"
local JSON = {
    name = "json",
    type = "lua"
}
print(json.beautify(JSON))
print(json.beautify(JSON, {
    newline = "\n",
    indent = "\t\t",
    depth = 0,
}))
```

* jsonc

```lua
local json = require "json"
require "jsonc"
local JSON = [[
{
    /*
     * comment
     */
    "name": "json", // comment
    "type": "lua",
}]]
local r = json.decode_jsonc(JSON)
print(r.name, r.type)
```

* json-edit

```lua
local json = require "json"
require "json-edit"
local JSON = [[
{
    /*
     * comment
     */
    "name": "json", // comment
    "type": "lua",
}]]

-- http://jsonpatch.com/
local patch = {
    op = "replace",
    path = "/name",
    value = "jsonc",
}
-- same as json.beautify
local option = {
    newline = "\n",
    indent = "    ",
}
print(json.edit(JSON, patch, option))
```

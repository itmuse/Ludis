-- lua demo
-- local json = require('cjson')
local tbl = {name = "hyson", age = 18, address = "China"}
-- print(json.encode(tbl))
local cjson = require "cjson"
-- 对象类型
local lua_object = {
        ["name"] = "Jiang",
        ["age"] = 24,
        ["addr"] = "BeiJing",
        ["email"] = "1569989xxxx@126.com",
        ["tel"] = "1569989xxxx"
}
local val = cjson.encode(lua_object)

print(val)
print("hello world")
for k, v in pairs(tbl) do
        print(k, v)
end
print("============")
local hmset = { "" }
table.insert(hmset, "hmset")
table.insert(hmset, "entity:person")
for k, v in pairs(lua_object) do
        print(k, v)
        table.insert(hmset, tostring(k))
        table.insert(hmset, tostring(v))
end
print("hmset redis command: ", table.concat(hmset, " "))
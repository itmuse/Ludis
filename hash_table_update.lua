
--[[
    基于redis的hash数据结构来存储对象的字段，在写入redis时，会自动增加一个字段 "__id__"，
    key的格式：key_id
    
    执行方法：
        redis-cli --eval "hash_table_update.lua" key , id json
    返回：
        [{ok: "OK"}]
    例子：
        redis-cli --eval "hash_table_update.lua" person , 6 '{"name":"Hyson Wu", "age":20}'
        redis-cli --eval "hash_table_update.lua" person , [6] '{"name":"Hyson Wu", "age":20}'
        redis-cli --eval "hash_table_update.lua" person , [3, 5] '[{"name":"Hyson Wu", "age":20}, {"name":"Kortee Chong", "age":30}]'
]]
if nil == KEYS[1] or nil == ARGV[1] or nil == ARGV[2] then
    return "['KEYS is required', 'ARGV is required: id json | [id] [json]']"
end
local obj = cjson.decode(ARGV[2])
local objArr = {}
if 0 == #obj then
    table.insert(objArr, obj)
else
    objArr = obj
end
if "[" ~= string.sub(ARGV[1], 1, 1) and "]" ~= string.sub(ARGV[1], -1) then
    ARGV[1] = '["'..ARGV[1]..'"]'
end
local id = cjson.decode(ARGV[1])
local idArr = {}
if 0 == #id then
    table.insert(idArr, id)
else
    idArr = id
end
local resArr = {}
for idx, val in pairs(objArr) do

    local res
    local params = {}
    for k, v in pairs(val) do
        if "__id__" ~= k then
            table.insert(params, k)
            table.insert(params, v)
        end
    end
    res = redis.call("HMSET", KEYS[1].."_"..idArr[idx], unpack(params))
    table.insert(resArr, res)
end
return cjson.encode(resArr)
--[[
    基于redis的hash数据结构来存储对象的字段，在写入redis时，会自动增加一个字段 "__id__"，
    key的格式：key_id

    执行方法：
        redis-cli --eval "hash_table_add.lua" key , json
    返回：
        [id]
    例子：
        redis-cli --eval "hash_table_add.lua" person , '{"name":"hyson wu", "age":18}'
        redis-cli --eval "hash_table_add.lua" person , '[{"name":"hyson wu", "age":18}, {"name":"kortee chong", "age":28}]'
]]
if nil == KEYS[1] or nil == ARGV[1] then
    return "['KEYS is required', 'ARGV is required: json | [json]']"
end
local obj = cjson.decode(ARGV[1])
local objArr = {}
if #obj == 0 then
    table.insert(objArr, obj)
else
    objArr = obj
end
local res
local ids = {}
local id_key = KEYS[1] .. "_ids"
for idx, val in pairs(objArr) do

    local num = redis.call("INCR", id_key)
    local params = {}
    table.insert(params, "__id__")
    table.insert(params, num)
    for k, v in pairs(val) do
        table.insert(params, k)
        table.insert(params, v)
    end
    res = redis.call("HMSET", KEYS[1].."_"..tostring(num), unpack(params))
    table.insert(ids, num)
end
return cjson.encode(ids)
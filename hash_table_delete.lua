--[[
    基于redis的hash数据结构来存储对象的字段，在写入redis时，会自动增加一个字段 "__id__"，
    key的格式：key_id
    删除一个对象时候，不会物理删除，增加一个字段做标识，"__del__" value 为 1
    
    执行方法：
        redis-cli --eval "hash_table_delete.lua" key , id | ids
    返回：
        [object]
    例子：
        redis-cli --eval "hash_table_delete.lua" person , 5
        redis-cli --eval "hash_table_delete.lua" person , [5, 7, 9]
]]
local key = KEYS[1]
local params = ARGV[1]
if nil == key or 0 == #key or nil == params or 0 == #params then
    return '["parameter is invalid", "key , id | ids"]'
end
local ids = cjson.decode(params)
local res = ''
if 'number' == type(ids) then
    res = redis.call('HSET', key..'_'..tostring(ids), '__del__', 1)
elseif 'table' == type(ids) then
    for i, id in pairs(ids) do
        res = redis.call('HSET', key..'_'..tostring(id), '__del__', 1)
    end    
end
return res

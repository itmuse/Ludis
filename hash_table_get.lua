
--[[
    基于redis的hash数据结构来存储对象的字段，在写入redis时，会自动增加一个字段 "__id__"，
    key的格式：key_id
    
    执行方法：
        redis-cli --eval "hash_table_get.lua" key , page_number | ids | fields | ids fields | fields page_number
    返回：
        [object]
    例子：
        redis-cli --eval "hash_table_get.lua" person
        redis-cli --eval "hash_table_get.lua" person , 5
        redis-cli --eval "hash_table_get.lua" person , [4, 5]
        redis-cli --eval "hash_table_get.lua" person , '["name"]'
        redis-cli --eval "hash_table_get.lua" person , [4, 5] '["name"]'
        redis-cli --eval "hash_table_get.lua" person , '["name"]' 1
]]
local arg_num = #ARGV
local key = KEYS[1]
local ids = {}
local fields = {}
local page_num = 1
if nil == key or 0 == #key or 3 <= arg_num then
    return '["parameters is invalid", " key , page_number | ids fields | fields page_number"]'
end

if nil == ARGV[1] or 0 == #ARGV[1] then
    ids = cjson.decode("[]")
else
    ids = cjson.decode(ARGV[1])
end
if nil == ARGV[2] or 0 == #ARGV[2] then
	fields = cjson.decode("[]")
else
	fields = cjson.decode(ARGV[2])
end
if 1 == arg_num and 'table' ~= type(ids) then
    page_num = tonumber(ARGV[1])
    ids = cjson.decode("[]")
end
if 1 == arg_num and nil ~= ids[1] and 'string' == type(ids[1]) then
    fields = ids
    ids = cjson.decode("[]")
end
if  2 == arg_num and 'table' ~= type(fields) then
    fields = ids
    ids = cjson.decode("[]")
    page_num = tonumber(ARGV[2])
end

local keys = {}
local page_size = 10
local start = page_size * (page_num - 1) + 1
local stop = page_size * page_num
if #ids == 0 then
    local num = redis.call('GET', key.."_ids")
    for i = start, tonumber(num) do
        if i > stop then
            break
        end
        table.insert(keys, key.."_"..tostring(i))
    end
else
    for i, id in pairs(ids) do
        table.insert(keys, key.."_"..tostring(id))
    end
end
local objArr = {}
for i, k in pairs(keys) do
    local res = {}
    local obj = {}
    if 0  == #fields then
        local del = redis.call('HGET', k, '__del__')
        if nil == del or 1 ~= tonumber(del) then
            res = redis.call("HGETALL", k)
            for j = 1, #res - 1, 2 do
                obj[res[j]] = res[j+1]
            end     
        end      
    else
        local del = redis.call('HGET', k, '__del__')
        if nil == del or 1 ~= tonumber(del) then
            table.insert(fields, 1, "__id__")
            res = redis.call("HMGET", k, unpack(fields))
            for j = 1, #res do
                obj[fields[j]] = res[j]
            end
        end
    end
    if nil ~= next(obj) then
        table.insert(objArr, obj)
    end

end
if nil == next(objArr) then
    table.insert(objArr, {})
end
return cjson.encode(objArr)
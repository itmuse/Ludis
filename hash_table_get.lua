local key = KEYS[1]
local params = {}
local fields = {}

if nil == ARGV[1] or 0 == #ARGV[1] then
    params = cjson.decode("[]")
else
    params = cjson.decode(ARGV[1])
end
if nil == ARGV[2] or 0 == #ARGV[2] then
	fields = cjson.decode("[]")
else
	fields = cjson.decode(ARGV[2])
end

local keys = {}
local pageSize = 10
if #params == 0 then
    local num = redis.call('GET', key.."_ids")
    for i = 1, tonumber(num) do
        if i > pageSize then
            break
        end
        table.insert(keys, key.."_"..tostring(i))
    end
else
    for i, id in pairs(params) do
        table.insert(keys, key.."_"..tostring(id))
    end
end
-- return cjson.encode({ params, fields, keys})
local objArr = {}
for i, k in pairs(keys) do
    local res = {}
    local obj = {}
    if 0  == #fields then
        res = redis.call("HGETALL", k)
        for j = 1, #res - 1, 2 do
            obj[res[j]] = res[j+1]
        end
    else
       table.insert(fields, 1, "__id__")
       res = redis.call("HMGET", k, unpack(fields))
       for j = 1, #res do
           obj[fields[j]] = res[j]
       end
    end
    table.insert(objArr, obj)

end
--local res1 = redis.call("HGETALL", keys[1])
return cjson.encode(objArr)
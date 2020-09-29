local obj = cjson.decode(ARGV[1])
local id_key = KEYS[1] .. "_ids"
local res
local objArr = {}
local ids = {}
if #obj == 0 then
    table.insert(objArr, obj)
else
    objArr = obj
end
for idx, val in pairs(objArr) do

    local num = redis.call("INCR", id_key)
    local params = {}
    table.insert(params, "__id__")
    table.insert(params, num)
    for k, v in pairs(val) do
        table.insert(params, k)
        table.insert(params, v)
    end
    res = redis.call('HMSET', KEYS[1].."_"..tostring(num), unpack(params))
    -- if ("OK" ~= res) then
    --     break
    -- end
    table.insert(ids, num)
end
return cjson.encode(ids)
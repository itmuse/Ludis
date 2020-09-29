local key = KEYS[1]
local params = {}
if ARGV[1] ~= nil then
	params = cjson.decode(ARGV[1])
else
	params = cjson.decode("[]")
end
local arr = {}
for str in string.gmatch(key..":", "([^:]+):") do
	table.insert(arr, str)
end
local res = nil
local obj = {}
if #params >= 1 then
	res = redis.call("HMGET", arr[1], unpack(params))
	for i = 1, #res do
		obj[params[i]] = res[i]
	end
else
	res = redis.call("HGETALL", arr[1])

	for i = 1, #res - 1, 2 do
		obj[res[i]] = res[i+1]
	end
end
return  cjson.encode(obj)
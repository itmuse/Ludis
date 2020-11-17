-- local cjson = require "cjson"
local obj = cjson.decode(ARGV[1])
local params = {}
for k, v in pairs(obj) do
	table.insert(params, tostring(k))
	table.insert(params, tostring(v))
end
local res = redis.call('HMSET', KEYS[1], unpack(params))
return res
-- IP限流，对某个IP频率进行限制 ，1分钟访问10次
local num = redis.call('incr',KEYS[1])
if tonumber(num) == 1 then
	redis.call('expire',KEYS[1],ARGV[1])
	return 1
elseif tonumber(num) > tonumber(ARGV[2]) then
	return 0
else
	return 1
end


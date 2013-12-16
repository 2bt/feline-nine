Object = {}
function Object:new(o)
	o = o or {}
	setmetatable(o, self)
	local m = getmetatable(self)
	self.__index = self
	self.__call = m.__call
	self.super = m.__index and m.__index.init
	return o
end
setmetatable(Object, { __call = function(self, ...)
	local o = self:new()
	if o.init then o:init(...) end
	return o
end })


bool = { [true] = 1, [false] = 0 }

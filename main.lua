require "helper"

local G = love.graphics
local isDown = love.keyboard.isDown

function newQuads(s, n, img)
	local q = {}
	for y = 0, n - 1 do
		for x = 0, n - 1 do
			local m = G.newMesh({
				{ -s/2, -s/2, (x+0)/n, (y+0)/n },
				{  s/2, -s/2, (x+1)/n, (y+0)/n },
				{  s/2,  s/2, (x+1)/n, (y+1)/n },
				{ -s/2,  s/2, (x+0)/n, (y+1)/n },
			}, img)
			table.insert(q, m)
		end
	end
	return q
end

function collision(a, b, axis)
	if a.x >= b.x + b.w
	or a.y >= b.y + b.h
	or a.x + a.w <= b.x
	or a.y + a.h <= b.y then
		return 0, 0
	end

	local dx = b.x + b.w - a.x
	local dx2 = b.x - a.x - a.w
	if -dx2 < dx then dx = dx2 end

	local dy = b.y + b.h - a.y
	local dy2 = b.y - a.y - a.h
	if -dy2 < dy then dy = dy2 end

	if axis == "x" then
		return dx, 0
	elseif axis == "y" then
		return 0, dy
	else
		if math.abs(dx) < math.abs(dy) then
			return dx, 0
		else
			return 0, dy
		end
	end
end



-- map
solids = {
	{
		x = 0,
		y = 470,
		w = 800,
		h = 200,
	}, {
		x = 200,
		y = 200,
		w = 200,
		h = 150,
	}, {
		x = 550,
		y = 300,
		w = 100,
		h = 100,
	}
}



Cat = Object:new()
function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(96, 4, img)

	self.anims = {
		idle	= { speed=0.04, 1, 2 },
		run		= { speed=0.10, 5, 6 },
		jump	= { speed=0.00, 7, 12, 8 },
	}

end
function Cat:init()
	self.x = 200
	self.y = 500
	self.dy = 0
	self.dir = 1

	self.frame = 0
	self.anim = self.anims["idle"]
end

function Cat:update()

	local dir = bool[isDown "right"] - bool[isDown "left"]
	self.x = self.x + dir * 5

	--self.dy = bool[isDown "down"] - bool[isDown "up"]
	self.dy = self.dy + 0.5
	self.y = self.y + self.dy

	local inAir = true

	-- collision
	local box = {
		x = self.x - 48,
		y = self.y - 12,
		w = 96, h = 12 + 48
	}
	self.box = box -- debug


	for _, s in ipairs(solids) do
		local ox, oy = collision(box, s)
		self.x = self.x + ox
		self.y = self.y + oy


		if oy < 0 and self.dy > 0 then -- hit floor
			self.dy = 0
			inAir = false
		end

		if oy > 0 and self.dy < 0 then -- ceiling cat :)
			self.dy = 0
		end
	end

	if not inAir then
		-- jump
		if isDown " " then
			self.dy = -14
		end
	end

	-- animation
	if inAir then
		self.anim = self.anims["jump"]
		if math.abs(self.dy) < 3 then self.frame = 1
		elseif self.dy < 0 then
			self.frame = 0
		else
			self.frame = 2
		end
	elseif dir ~= 0 then
		self.dir = dir
		self.anim = self.anims["run"]
	else
		self.anim = self.anims["idle"]
	end

	self.frame = self.frame + self.anim.speed % #self.anim


end
function Cat:draw()
	G.setColor(255, 0, 0)
	G.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)


	G.setColor(255, 255, 255)
	local i = math.floor(self.frame % #self.anim) + 1


	G.draw(self.quads[self.anim[i]], self.x, self.y, 0, self.dir, 1)
end




function love.load()
	G.setDefaultFilter("nearest", "nearest")
	font = G.newFont("data/grumpy-cat.ttf", 100)
	G.setFont(font)

	Cat:staticInit()
	player = Cat()


	G.setBackgroundColor(100, 100, 100)
end

function love.update()

	player:update()
end

function love.draw()

	G.setColor(255, 255, 255)
	G.printf("feline", 100, 100, 0, "left")
	G.setColor(200, 0, 0)
	G.printf("nine", 700, 200, 0, "right")



	player:draw()


	for _, s in ipairs(solids) do
		G.setColor(30, 20, 0)
		G.rectangle("line", s.x, s.y, s.w, s.h)
		G.setColor(70, 50, 20)
		G.rectangle("fill", s.x, s.y, s.w, s.h)
	end

end

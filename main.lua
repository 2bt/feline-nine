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

	local dy = b.y + b.h - a.y
	local dy2 = b.y - a.y - a.h

	if axis == "x" then
		return dx, dx2
	elseif axis == "y" then
		return dy, dy2
	else
		if -dx2 < dx then dx = dx2 end
		if -dy2 < dy then dy = dy2 end
		if math.abs(dx) < math.abs(dy) then
			return dx, 0
		else
			return 0, dy
		end
	end
end


pixelSize = 6
-- map
solids = {
	{
		x = -100,
		y = 78,
		w = 233,
		h = 100,
	}, {
		x = 32,
		y = 32,
		w = 16,
		h = 16,
	}, {
		x = 48,
		y = 32,
		w = 16,
		h = 16,
	}, {
		x = 48,
		y = 48,
		w = 16,
		h = 16,
	}, {
		x = 95,
		y = 50,
		w = 16,
		h = 16,
	}, {
		x = 120,
		y = 0,
		w = 8,
		h = 30,
	}, {
		x = 120,
		y = 32,
		w = 8,
		h = 34,
	}
}


Cat = Object:new()
function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(96, 4, img)

	self.anims = {
		idle	= { speed=2.5/60, 1, 2 },
		run		= { speed=5/60, 5, 6 },
		jump	= { speed=0.00, 7, 12, 8 },
		hang	= { speed=0.00, 9, 10, 11, 12 },
	}

end
function Cat:init()
	self.x = 5
	self.y = 20

	self.dy = 0
	self.dir = 1

	self.state = "air"
	self.anim = self.anims["jump"]
	self.frame = 0
end

function Cat:update()

	local dir = 0
	if self.state == "ground"
	or self.state == "air" then

		dir = bool[isDown "right"] - bool[isDown "left"]
		if dir ~= 0 then self.dir = dir end
		self.x = self.x + dir * 1.1

		--self.dy = bool[isDown "down"] - bool[isDown "up"]
		self.dy = self.dy + 0.1
		self.y = self.y + self.dy

		-- collision box
		local box = {
			x = self.x - 7,
			y = self.y - 3,
			w = 14,
			h = 11
		}
		self.box = box -- debug

		-- collision
		local state = "air"
		for _, s in ipairs(solids) do
			local ox, oy = collision(box, s)
			self.x = self.x + ox
			self.y = self.y + oy

			if oy < 0 and self.dy > 0 then -- hit floor
				self.dy = 0
				state = "ground"
			end

			if oy > 0 and self.dy < 0 then -- ceiling cat :)
				self.dy = 0
			end

			-- hang
			if self.dy > 0 and self.state == "air" and ox ~= 0 then
				_, dy = collision(box, s, "y")
				if dy < -11 and dy > -14 then
					self.y = self.y + dy + 14
					self.x = self.x + self.dir
					self.state = "hang"
					self.frame = 0
					return
				end

			end
		end
		self.state = state

		-- jump
		if self.state == "ground" then
			if isDown " " then
				self.dy = -2.7
			end
		end

	elseif self.state == "hang" then

		local frame = self.frame
		self.frame = self.frame + 0.1
		if frame < 1 and self.frame >= 1 then
			self.x = self.x + 3 * self.dir
			self.y = self.y - 7
		elseif frame < 2 and self.frame >= 2 then
			self.x = self.x + 1 * self.dir
			self.y = self.y - 3
		elseif frame < 3 and self.frame >= 3 then
			self.x = self.x + 4 * self.dir
			self.y = self.y - 4
		elseif frame < 4 and self.frame >= 4 then
			self.state = "ground"
		end
	end

	-- animation
	if self.state == "air" then
		self.anim = self.anims["jump"]
		if math.abs(self.dy) < 0.5 then self.frame = 1
		elseif self.dy < 0 then
			self.frame = 0
		else
			self.frame = 2
		end
	elseif self.state == "ground" then
		if dir ~= 0 then
			self.anim = self.anims["run"]
		else
			self.anim = self.anims["idle"]
		end
	elseif self.state == "hang" then
		self.anim = self.anims["hang"]
	end

	self.frame = self.frame + self.anim.speed % #self.anim

end
function Cat:draw()
	-- debug box
	G.setColor(255, 0, 0)
	G.rectangle("line", 
		self.box.x*pixelSize, 
		self.box.y*pixelSize, 
		self.box.w*pixelSize, 
		self.box.h*pixelSize)

	G.setColor(255, 255, 255)
	local i = math.floor(self.frame % #self.anim) + 1


	G.draw(self.quads[self.anim[i]], self.x*pixelSize, self.y*pixelSize, 0, self.dir, 1)
end

function love.load()
	G.setDefaultFilter("nearest", "nearest")
	font = G.newFont("data/grumpy-cat.ttf", 100)
	G.setFont(font)

	Cat:staticInit()
	player = Cat()

	G.setBackgroundColor(80, 80, 110)
end

function love.update()
	player:update()
end

function love.draw()

--	print("TEST")
	G.setColor(255, 255, 255)
	G.printf("feline", 100, 100, 0, "left")
	G.setColor(200, 0, 0)
	G.printf("nine", 700, 200, 0, "right")

	G.setColor(30, 20, 0)
	for _, s in ipairs(solids) do
		G.rectangle("fill", 
			s.x*pixelSize, 
			s.y*pixelSize, 
			s.w*pixelSize, 
			s.h*pixelSize)
	end
	G.setColor(170, 0, 0)
	for _, s in ipairs(solids) do
		G.setLineWidth(2)
		G.rectangle("line", 
			s.x*pixelSize, 
			s.y*pixelSize, 
			s.w*pixelSize, 
			s.h*pixelSize)
	end

	player:draw()

end

function love.keypressed(key)
	print(key)
	if key == "escape" then
		love.event.quit()
	end
end

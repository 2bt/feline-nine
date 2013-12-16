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




Cat = Object:new()
function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(100, 4, img)

	self.anims = {
		idle	= { speed=0.04, 1, 2 },
		run		= { speed=0.10, 5, 6 },
		jump	= { speed=0.00, 7, 12, 8 },
	}

end
function Cat:init()
	self.x = 200
	self.y = 0
	self.dy = 0
	self.dir = 1

	self.frame = 0
	self.anim = self.anims["idle"]
end
function Cat:update()

	local dir = bool[isDown "right"] - bool[isDown "left"]
	self.x = self.x + 4 * dir


	self.dy = self.dy + 0.5
	self.y = self.y + self.dy

	local inAir = true

	if self.y > 400 then
		inAir = false
		self.y = 400
		self.dy = 0

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
	G.setColor(70, 70, 30)
--	G.rectangle("line", self.x-20, self.y-20, 40, 40)
	G.rectangle("fill", 0, 450, 800, 200)


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
end

-- states:
local fall = 0
local stand = 1
local walk = 2
local run = 3
local crawl = 4
local hang = 5
local climb = 6

Cat = Object:new()

function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(96, 4, img)

	self.anims = {
		idle	= { speed=150/60/60, 1, 2 },
		run		= { speed=5/60, 5, 6 },
		jump	= { speed=0.00, 7, 12, 8 },
		hang	= { speed=0.00, 9, 10, 11, 12 },
	}

end

function Cat:init()
	self.x = 10
	self.y = 20

	self.dy = 0
	self.dir = 1

	self.state = "air"
	self.anim = self.anims["fall"]
	self.frame = 0
	
	self.walkXSpeed = 1.1;
	self.fallXSpeed = 1.1;
	
end

function Cat:update1()
	local moveX = bool[isDown "right"] - bool[isDown "left"]
	if moveX ~= 0 then self.dir = moveX end
	local spacePressed = bool[isDown "space"]
	local upPressed = bool[isDown "up"]
	local downPressed = bool[isDown "down"]
	
	if self.state == fall then
		
	elseif self.state == stand then
		
	elseif self.state == walk then
		
	elseif self.stare == run then
		
	elseif self.state == crawl then
		
	elseif self.state == hang then
		
	elseif state == climb then
		
	else
		-- unknown state, what to do here?
	end
	


	local dir = 0
	if self.state == "ground"
	or self.state == "air" then

		dir = bool[isDown "right"] - bool[isDown "left"]
		if dir ~= 0 then self.dir = dir end
		self.x = self.x + dir * self.walkXSpeed

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


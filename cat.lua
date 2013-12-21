Cat = Object:new()

function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(96, 4, img)

	self.anims = {
		idle	= { speed=150/60/60, 1, 2 },
		run		= { speed=5/60, 5, 6 },
		jump	= { speed=0.00, 7, 12, 8 },
		hang	= { speed=0.10, 9, 10 },
		climb	= { speed=0.00, 9, 10, 11, 12 },
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

	self.walkXSpeed = 1.1
	self.fallXSpeed = 1.1

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
	-- ...
end


function Cat:update()

	local dir = 0
	if self.state == "ground"
	or self.state == "air" then


		-- horizontal movement
		dir = bool[isDown "right"] - bool[isDown "left"]
		if dir ~= 0 then self.dir = dir end
		self.x = self.x + dir * self.walkXSpeed

		local box = {
			x = self.x - 7,
			y = self.y - 3,
			w = 14,
			h = 11
		}

		local ox = 0
		local edgeBox = nil

		for _, s in ipairs(solids) do
			local x1, x2 = collision(box, s, "x")
			local px = 0
			if math.abs(x1) < math.abs(x2) then
				px = x1
			else
				px = x2
			end
			if math.abs(px) > math.abs(ox) then
				ox = px
				edgeBox = s
			end
		end

		self.x = self.x + ox

		-- hang
		if self.dy > 0 and self.state == "air" and edgeBox then
			local _, dy = collision(box, edgeBox, "y")
			if dy < -11 and dy > -14 then

				local free = true
				local box = {
					x = self.x - 7 + self.dir * 3,
					y = self.y - 3 + 9 + dy,
					w = 14,
					h = 2
				}
				self.box2 = box -- debug

				for _, s in ipairs(solids) do
					local fx, fy = collision(box, s)
					if fx ~= 0 or fy ~= 0 then
						free = false
						break
					end
				end

				if free then
					self.y = self.y + dy + 14
					self.x = self.x + self.dir
					self.dy = 0
					self.state = "hang"
					self.frame = 0
					return -- this might break things
				end
			end
		end



		-- vertical movement

		self.dy = self.dy + 0.1
		self.y = self.y + self.dy

		local box = {
			x = self.x - 7,
			y = self.y - 3,
			w = 14,
			h = 11
		}

		local oy = 0
		for _, s in ipairs(solids) do
			local y1, y2 = collision(box, s, "y")
			local py = 0
			if math.abs(y1) < math.abs(y2) then
				py = y1
			else
				py = y2
			end
			if math.abs(py) > math.abs(oy) then
				oy = py
			end
		end

		self.y = self.y + oy


		if oy < 0 and self.dy > 0 then -- hit floor
			self.dy = 0
			self.state = "ground"
		else
			self.state = "air"
		end

		if oy > 0 and self.dy < 0 then -- ceiling cat :)
			self.dy = 0
		end



		-- jump
		if self.state == "ground" then
			if isDown " " then
				self.dy = -2.7
			end
		end

		self.box = box

	elseif self.state == "hang" then
		if isDown("down")
		or isDown(self.dir == 1 and "left" or "right") then
			self.state = "air"
		elseif isDown("up") then


			local free = true



			self.state = "climb"
			self.frame = 0.7
		end

	elseif self.state == "climb" then

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
		if math.abs(self.dy) < 0.5 then
			self.frame = 1
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
	elseif self.state == "climb" then
		self.anim = self.anims["climb"]
	end

	self.frame = self.frame + self.anim.speed % #self.anim

end
function Cat:draw()
	-- debug box
	G.setColor(255, 0, 0)
	drawBox(self.box)
	if self.box2 then
		drawBox(self.box2)
	end

	G.setColor(255, 255, 255)
	local i = math.floor(self.frame % #self.anim) + 1

	G.draw(self.quads[self.anim[i]], self.x*PIXEL_SIZE, self.y*PIXEL_SIZE, 0, self.dir, 1)
end


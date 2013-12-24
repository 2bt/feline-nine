Cat = Object:new()

-- this controls the beat counter reset
-- keep as low as possible to avoid float rounding errors
local MUSIC_TIMER_RING_SIZE = 4

local DRAW_DEBUG_BOXES = true

function Cat:staticInit()

	local img = G.newImage("data/cat.png")
	self.quads = newQuads(96, 8, img)

	self.anims = {
		idle	= { speed=1.00, 1, 2, 3, 4 },
		walk	= { speed=0.20, 9, 10, 11, 12, 13, 14, 15, 16 },
		jump	= { speed=0.00, 17, 18, 19 },
		hang	= { speed=1.00, 25, 26, 27, 28 },
		climb	= { speed=0.00, 28, 29, 30, 31 },
	}

end

function Cat:init()
	self.x = 10
	self.y = 60

	self.dy = 0
	self.dir = 1

	self.state = "air"
	self.anim = self.anims["fall"]
	self.frame = 0

	self.lastIdleX = self.x
	self:musicUpdated()
end

function Cat:musicUpdated()
	self.idleAnimationCounter = 0
end

-- suggestion: separate Cat:update(justTime) into Cat:updateTime() and Cat:updateMovement(leftBttn, rightBttn, upBttn, downBttn, jumpBttn)
		--> update time only when no movement is happening, keeping head bobbing synced to music
		--> movement with button strings as parameters enables multi player
function Cat:update(justTime)
	local time = love.timer.getDelta()
	self.idleAnimationCounter = (self.idleAnimationCounter + time * MUSIC_BPM / 60) % MUSIC_TIMER_RING_SIZE
	if justTime then return end
	
	if self.platform then
		self.y = self.y + self.platform.dy
		self.x = self.x + self.platform.dx
	end

	local jump = isDown " "

	local dir = 0
	if self.state == "ground"
	or self.state == "air" then

		-- horizontal movement
		dir = bool[isDown "right"] - bool[isDown "left"]
		if dir ~= 0 then self.dir = dir end
		self.x = self.x + dir * 0.9

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
				for _, s in ipairs(solids) do
					local fx, fy = collision(box, s)
					if fx ~= 0 or fy ~= 0 then
						free = false
						break
					end
				end

				if free then

					-- is this edge climbable?
					local box = {
						x = self.x - 7 + self.dir * 3,
						y = self.y - 3 + dy,
						w = 14,
						h = 11
					}
					self.climb = true
					for _, s in ipairs(solids) do
						local fx, fy = collision(box, s)
						if fx ~= 0 or fy ~= 0 then
							self.climb = false
							break
						end
					end

					self.y = self.y + dy + 14
					self.x = self.x + self.dir
					self.dy = 0
					self.state = "hang"
					self.frame = 0
					if edgeBox.dynamic then
						self.platform = edgeBox
					end
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

		local floorBox = nil
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
				floorBox = s
			end
		end

		self.y = self.y + oy


		if oy < 0 and self.dy > 0 then -- hit floor
			self.dy = 0
			self.state = "ground"
			if floorBox.dynamic then
				self.platform = floorBox
			end
		else
			self.state = "air"
			self.platform = nil
		end

		if oy > 0 and self.dy < 0 then -- ceiling cat :)
			self.dy = 0
		end



		-- jump
		if self.state == "ground" then
			if jump and not self.lastJump then
				self.dy = -2.7
			end
		end

		self.box = box

	elseif self.state == "hang" then
		if isDown "down"
		or isDown(self.dir == 1 and "left" or "right") then
			self.state = "air"

		elseif self.climb and isDown "up" then
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


	self.lastJump = jump



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
			self.anim = self.anims["walk"]
		else
			self.anim = self.anims["idle"]
			self.lastIdleX = self.x
		end
	elseif self.state == "hang" then
		self.anim = self.anims["hang"]
	elseif self.state == "climb" then
		self.anim = self.anims["climb"]
	end

	self.frame = self.frame + self.anim.speed % #self.anim

end

function Cat:draw()
	if DRAW_DEBUG_BOXES then
		G.setColor(255, 0, 0)
		drawBox(self.box)
		if self.box2 then drawBox(self.box2) end
	end

	G.setColor(255, 255, 255)
	local i = math.floor(self.frame) % #self.anim + 1
	if self.anim == self.anims.idle or self.anim == self.anims.hang then
		i = math.floor(self.idleAnimationCounter * self.anim.speed) % #self.anim + 1
	end

	G.draw(self.quads[self.anim[i]], self.x*PIXEL_SIZE, self.y*PIXEL_SIZE, 0, self.dir, 1)
end


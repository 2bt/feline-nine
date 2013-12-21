require "helper"
require "cat"

G = love.graphics
isDown = love.keyboard.isDown


PIXEL_SIZE = 6


-- map
platform = {
	dynamic = true,
	xx = 5,
	yy = 32,

	dx = 0,
	dy = 0,
	x = 0,
	y = 0,
	w = 20,
	h = 2
}

solids = {
	platform,
	{ x = -100, y = 78, w = 233, h = 100 },
--	{ x =   32, y = 32, w =  16, h =  16 },
	{ x =   48, y = 32, w =  16, h =  16 },
	{ x =   48, y = 48, w =  16, h =  16 },
	{ x =   95, y = 52, w =  4, h =  16 },
	{ x =  120, y =  0, w =   8, h =  30 },
	{ x =  120, y = 32, w =   8, h =  34 }
}



-- helper

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

function drawBox(box)
	G.rectangle("line",
		box.x * PIXEL_SIZE,
		box.y * PIXEL_SIZE,
		box.w * PIXEL_SIZE,
		box.h * PIXEL_SIZE)
end




-- the real stuff

function love.load()
	G.setDefaultFilter("nearest", "nearest")
	font = G.newFont("data/grumpy-cat.ttf", 100)
	G.setFont(font)

	Cat:staticInit()
	player = Cat()

	G.setBackgroundColor(80, 80, 110)
end


local tick = 0
function love.update()


	-- test
	local x = platform.x
	local y = platform.y
	platform.x = platform.xx + math.sin(tick) * 4
	platform.y = platform.yy + math.cos(tick) * 20
	tick = tick + 0.01
	platform.dx = platform.x - x
	platform.dy = platform.y - y


	player:update()
end



function love.draw()

	G.setColor(255, 255, 255)
	G.printf("feline", 100, 100, 0, "left")
	G.setColor(200, 0, 0)
	G.printf("nine", 700, 200, 0, "right")

	G.setColor(30, 20, 0)
	for _, s in ipairs(solids) do
		drawBox(s)
		G.rectangle("fill",
			s.x * PIXEL_SIZE,
			s.y * PIXEL_SIZE,
			s.w * PIXEL_SIZE,
			s.h * PIXEL_SIZE)
	end
	G.setColor(170, 0, 0)
	for _, s in ipairs(solids) do
		G.setLineWidth(2)
--		drawBox(s)
	end

	player:draw()


end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

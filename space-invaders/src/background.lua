local background = {}

local stars = {}
local screenWidth, screenHeight

function background.load()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    local starCount = 150

    stars = {}
    for i = 1, starCount do
        table.insert(stars, {
            x = math.random(0, screenWidth),
            y = math.random(0, screenHeight),
            size = math.random(1, 4),
            speed = math.random(20, 100)
        })
    end
end

function background.update(dt)
    for _, star in ipairs(stars) do
        star.y = star.y + star.speed * dt
        if star.y > screenHeight then
            star.y = 0
            star.x = math.random(0, screenWidth)
            star.size = math.random(1, 4)
            star.speed = math.random(20, 100)
        end
    end
end

function background.draw()
    love.graphics.setColor(1, 1, 1)
    for _, star in ipairs(stars) do
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end
end

function background.resize(w, h)
    local oldWidth, oldHeight = screenWidth, screenHeight
    screenWidth, screenHeight = w, h

    for _, star in ipairs(stars) do
        star.x = (star.x / oldWidth) * screenWidth
        star.y = (star.y / oldHeight) * screenHeight
    end
end

return background

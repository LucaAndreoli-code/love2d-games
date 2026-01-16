local background = {}

local stars = {}
local GAME_WIDTH = 800
local GAME_HEIGHT = 600

function background.load()
    local starCount = 150

    stars = {}
    for i = 1, starCount do
        table.insert(stars, {
            x = math.random(0, GAME_WIDTH),
            y = math.random(0, GAME_HEIGHT),
            size = math.random(1, 4),
            speed = math.random(20, 100)
        })
    end
end

function background.update(dt)
    for _, star in ipairs(stars) do
        star.y = star.y + star.speed * dt
        if star.y > GAME_HEIGHT then
            star.y = 0
            star.x = math.random(0, GAME_WIDTH)
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

return background

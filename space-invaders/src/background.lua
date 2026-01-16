local scaling = require("src.scaling")
local colorsConst = require("src.constants.colors")
local gameConst = require("src.constants.game")

local background = {}

local stars = {}

function background.load()
    local starCount = gameConst.STAR_COUNT

    stars = {}
    for i = 1, starCount do
        table.insert(stars, {
            x = math.random(0, scaling.GAME_WIDTH),
            y = math.random(0, scaling.GAME_HEIGHT),
            size = math.random(gameConst.STAR_SIZE_MIN, gameConst.STAR_SIZE_MAX),
            speed = math.random(gameConst.STAR_SPEED_MIN, gameConst.STAR_SPEED_MAX)
        })
    end
end

function background.update(dt)
    for _, star in ipairs(stars) do
        star.y = star.y + star.speed * dt
        if star.y > scaling.GAME_HEIGHT then
            star.y = 0
            star.x = math.random(0, scaling.GAME_WIDTH)
            star.size = math.random(gameConst.STAR_SIZE_MIN, gameConst.STAR_SIZE_MAX)
            star.speed = math.random(gameConst.STAR_SPEED_MIN, gameConst.STAR_SPEED_MAX)
        end
    end
end

function background.draw()
    love.graphics.setColor(colorsConst.WHITE)
    for _, star in ipairs(stars) do
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end
end

return background

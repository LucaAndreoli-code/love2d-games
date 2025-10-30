Constants = require("src.constants")

local Sprites = {}

function Sprites.load()
    local imageData = love.image.newImageData("resources/sprite/frogger.png")
    local width = imageData:getWidth()
    local height = imageData:getHeight()

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local r, g, b, a = imageData:getPixel(x, y)

            if r == 0 and g == 0 and b == 0 then
                imageData:setPixel(x, y, r, g, b, 0)
            end
        end
    end

    local spritesheet = love.graphics.newImage(imageData)
    spritesheet:setFilter("nearest", "nearest") -- mantieni pixel sharp

    local px16 = 16

    local frogPosX = 1
    local frogPosY = 1

    local sprites = {}

    sprites.frog = love.graphics.newQuad(
        frogPosX, frogPosY, -- x, y posizione nello spritesheet
        px16, px16,         -- width, height dello sprite
        spritesheet:getDimensions()
    )

    sprites.frogJump = love.graphics.newQuad(
        frogPosX + px16 + 2, frogPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local carPosX = 1
    local carPosY = 116

    sprites.car = love.graphics.newQuad(
        carPosX, carPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    sprites.sportCar = love.graphics.newQuad(
        carPosX + px16 + 2, carPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    sprites.truck = love.graphics.newQuad(
        carPosX + (px16 + 2) * 4, carPosY,
        px16 * 2, px16,
        spritesheet:getDimensions()
    )

    local logPosX = 1
    local logPosY = 134

    sprites.left_log = love.graphics.newQuad(
        logPosX, logPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    sprites.center_log = love.graphics.newQuad(
        logPosX + (px16 + 2), logPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    sprites.right_log = love.graphics.newQuad(
        logPosX + (px16 * 2 + 2 + 2), logPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local turtlePosX = 1
    local turtlePosY = 152

    sprites.turtle = love.graphics.newQuad(
        turtlePosX + (px16 + 2), turtlePosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local lilypadPosX = 55
    local lilypadPosY = 152

    sprites.lilypad = love.graphics.newQuad(
        lilypadPosX, lilypadPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local crocodilePosX = 41
    local crocodilePosY = 134

    sprites.crocodile = love.graphics.newQuad(
        (crocodilePosX + px16 * 4), crocodilePosY,
        px16 * 3, px16,
        spritesheet:getDimensions()
    )

    local frogOnLilyPadPosX = 45
    local frogOnLilyPadPosY = 196

    sprites.frog_on_lilypad = love.graphics.newQuad(
        frogOnLilyPadPosX, frogOnLilyPadPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local waterPosX = 1
    local waterPosY = 390

    sprites.water = love.graphics.newQuad(
        waterPosX, waterPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local roadPosX = 90
    local roadPosY = 378

    -- Create a full black quad for the road
    sprites.road = love.graphics.newQuad(
        roadPosX, roadPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local safePosX = 135
    local safePosY = 197

    sprites.safe = love.graphics.newQuad(
        safePosX, safePosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    local deathPosX = 109
    local deathPosY = 80

    sprites.death = love.graphics.newQuad(
        deathPosX, deathPosY,
        px16, px16,
        spritesheet:getDimensions()
    )

    return { sheet = spritesheet, quads = sprites }
end

function Sprites:drawLanesBackground(lane, laneY)
    -- Draw lane background
    local quadToDraw = nil
    if lane.type == 'water' then
        quadToDraw = GameSprites.quads.water
    elseif lane.type == 'road' then
        quadToDraw = GameSprites.quads.road
    elseif lane.type == 'safe' then
        quadToDraw = GameSprites.quads.safe
    else
        return -- no background to draw for 'safe' lanes
    end

    for i = 0, Constants.GRID_WIDTH - 1 do
        love.graphics.draw(
            GameSprites.sheet,
            quadToDraw,
            i * (Constants.GAME_WIDTH / Constants.GRID_WIDTH) + 8,
            laneY + 8,
            0,
            1, 1,
            8, 8
        )
    end
end

function Sprites:drawObstacles(obstacle, ObstacleWidth, lane, laneY, direction)
    -- Draw obstacle
    if obstacle.type == 'car' then
        local carQuad = GameSprites.quads.car
        if (lane.speed > 120) then
            carQuad = GameSprites.quads.sportCar
        end


        love.graphics.draw(
            GameSprites.sheet,
            carQuad,
            obstacle.x + 8,
            laneY + 8,
            direction,
            1, 1,
            8, 8
        )
    elseif obstacle.type == 'truck' then
        local truckQuad = GameSprites.quads.truck

        love.graphics.draw(
            GameSprites.sheet,
            truckQuad,
            obstacle.x + 8,
            laneY + 8,
            direction,
            1, 1,
            8, 8
        )
    elseif obstacle.type == 'log' then
        local rightLog = GameSprites.quads.right_log
        local leftLog = GameSprites.quads.left_log
        local centerLog = GameSprites.quads.center_log

        if obstacle.width == ObstacleWidth * 3 then
            love.graphics.draw(
                GameSprites.sheet,
                leftLog,
                obstacle.x + 8,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
            love.graphics.draw(
                GameSprites.sheet,
                centerLog,
                obstacle.x + 8 + ObstacleWidth,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
            love.graphics.draw(
                GameSprites.sheet,
                rightLog,
                obstacle.x + 8 + ObstacleWidth * 2,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
        elseif obstacle.width == ObstacleWidth * 2 then
            love.graphics.draw(
                GameSprites.sheet,
                leftLog,
                obstacle.x + 8,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
            love.graphics.draw(
                GameSprites.sheet,
                rightLog,
                obstacle.x + 8 + ObstacleWidth,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
        elseif obstacle.width == ObstacleWidth then
            love.graphics.draw(
                GameSprites.sxheet,
                centerLog,
                obstacle.x + 8,
                laneY + 8,
                0, --no need for direction
                1, 1,
                8, 8
            )
        end
    elseif obstacle.type == 'turtle' then
        local turtleQuad = GameSprites.quads.turtle

        love.graphics.draw(
            GameSprites.sheet,
            turtleQuad,
            obstacle.x + 8,
            laneY + 8,
            0, --no need for direction
            1, 1,
            8, 8
        )
    elseif obstacle.type == 'crocodile' then
        local crocodileQuad = GameSprites.quads.crocodile

        love.graphics.draw(
            GameSprites.sheet,
            crocodileQuad,
            obstacle.x + 8,
            laneY + 8,
            0, --no need for direction
            1, 1,
            8, 8
        )
    end
end

return Sprites

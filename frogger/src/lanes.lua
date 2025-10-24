local Constants = require("src.constants")
local Frogger = require("src.frogger")
local Debug = require("src.debug")

local TileWidth = Constants.GAME_WIDTH / Constants.GRID_WIDTH

local Lanes = {
    {
        type = 'end',
        speed = 0,
        direction = 0,
        obstacles = {}
    },

    {
        type = 'road',
        speed = 20,
        direction = -1,
        obstacles = {
            { x = 0,  type = 'car',   width = TileWidth },
            { x = 45, type = 'truck', width = TileWidth * 2 },
            { x = 90, type = 'car',   width = TileWidth }
        }
    },
    {
        type = 'road',
        speed = 40,
        direction = -1,
        obstacles = {
            { x = 25, type = 'truck', width = TileWidth * 2 },
            { x = 80, type = 'car',   width = TileWidth },
        }
    },
    {
        type = 'road',
        speed = 20,
        direction = 1,
        obstacles = {
            { x = 0,   type = 'car', width = TileWidth },
            { x = 75,  type = 'car', width = TileWidth },
            { x = 125, type = 'car', width = TileWidth }
        }
    },
    {
        type = 'road',
        speed = 80,
        direction = 1,
        obstacles = {
            { x = 0,  type = 'car', width = TileWidth },
            { x = 75, type = 'car', width = TileWidth }
        }
    },
    {
        type = 'safe',
        speed = 0,
        direction = 0,
        obstacles = {}
    },
    {
        type = 'water',
        speed = 20,
        direction = 1,
        obstacles = {
            { x = 0,   type = 'log',       width = TileWidth * 2 },
            { x = 100, type = 'crocodile', width = TileWidth * 3 },
            { x = 50,  type = 'log',       width = TileWidth * 3 },
        }
    },
    {
        type = 'water',
        speed = 15,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'turtle', width = TileWidth },
            { x = 100, type = 'turtle', width = TileWidth },
        }
    },
    {
        type = 'water',
        speed = 35,
        direction = 1,
        obstacles = {
            { x = 0,   type = 'log', width = TileWidth * 2 },
            { x = 125, type = 'log', width = TileWidth * 3 }
        }
    },
    {
        type = 'water',
        speed = 40,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'log', width = TileWidth * 2 },
            { x = 125, type = 'log', width = TileWidth * 2 }
        }
    },
    {
        type = 'water',
        speed = 30,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'turtle', width = TileWidth },
            { x = 125, type = 'log',    width = TileWidth * 2 },
            { x = 200, type = 'turtle', width = TileWidth }
        }
    },
    {
        type = 'safe',
        speed = 0,
        direction = 0,
        obstacles = {}
    }
}

--can be randomized later
function Lanes:init()
    --RANDOMIZE LANES LATER
end

function Lanes:draw()
    for index = #Lanes, 1, -1 do
        local lane = Lanes[index]
        local laneY = (index - 1) * LaneHeight

        -- Draw lane border
        --love.graphics.setColor(1, 1, 1, 1)
        if (Debug.enabled) then
            love.graphics.rectangle('line', 0, laneY, Constants.GAME_WIDTH, LaneHeight)
        end

        -- Draw lane tiles
        local numTiles = (lane.type == 'end') and NUM_LILIPAD or GRID_WIDTH
        local useSpacing = (lane.type == 'end')

        -- Calculate gap once
        local gapSize = 0
        if useSpacing then
            local totalTilesWidth = numTiles * TileWidth
            local remainingSpace = Constants.GAME_WIDTH - totalTilesWidth
            gapSize = remainingSpace / (numTiles - 1)
        end

        -- Draw tiles
        for i = 1, numTiles do
            -- Set color based on lane type
            if (lane.type == 'road') then
                love.graphics.setColor(1, 0, 0, 0.5)
            elseif (lane.type == 'water') then
                love.graphics.setColor(0, 0, 1, 0.5)
            else
                love.graphics.setColor(0, 1, 0, 0.5)
            end
            local x = (i - 1) * (TileWidth + gapSize)
            love.graphics.rectangle('fill', x, laneY, TileWidth, LaneHeight)
        end
    end
end

function Lanes:drawObstacles()
    for index = #Lanes, 1, -1 do
        local lane = Lanes[index]
        local laneY = (index - 1) * LaneHeight
        local isOnAnyPlatform = false

        for _, obstacle in ipairs(lane.obstacles) do
            -- Update obstacle position
            obstacle.x = obstacle.x + lane.speed * lane.direction * love.timer.getDelta()

            -- Wrap around logic
            if lane.direction == 1 and obstacle.x > Constants.GAME_WIDTH then
                obstacle.x = -TileWidth
            elseif lane.direction == -1 and obstacle.x < -TileWidth then
                obstacle.x = Constants.GAME_WIDTH
            end

            local direction = 0
            if (lane.direction == 1) then
                direction = -math.pi
            end

            love.graphics.setColor(1, 1, 1, 1)

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

                if obstacle.width == TileWidth * 3 then
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
                        obstacle.x + 8 + TileWidth,
                        laneY + 8,
                        0, --no need for direction
                        1, 1,
                        8, 8
                    )
                    love.graphics.draw(
                        GameSprites.sheet,
                        rightLog,
                        obstacle.x + 8 + TileWidth * 2,
                        laneY + 8,
                        0, --no need for direction
                        1, 1,
                        8, 8
                    )
                elseif obstacle.width == TileWidth * 2 then
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
                        obstacle.x + 8 + TileWidth,
                        laneY + 8,
                        0, --no need for direction
                        1, 1,
                        8, 8
                    )
                elseif obstacle.width == TileWidth then
                    love.graphics.draw(
                        GameSprites.sheet,
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

            if (Debug.enabled) then
                love.graphics.rectangle('line', obstacle.x, laneY, obstacle.width, LaneHeight)
                love.graphics.print(obstacle.type, obstacle.x + 5, laneY + 5)
            end

            -- Check if Frogger is on this obstacle
            if not Frogger.isHopping then
                if Frogger:isOnPlatform(obstacle, laneY) then
                    if lane.type == 'road' then
                        -- Hit by vehicle
                        if obstacle.type == 'car' or obstacle.type == 'truck' then
                            print("Game Over! Hit by vehicle")
                            Frogger:resetPosition()
                        end
                    elseif lane.type == 'water' then
                        isOnAnyPlatform = true

                        if obstacle.type == 'crocodile' then
                            print("Game Over! Eaten by crocodile")
                            Frogger:resetPosition()
                        else
                            Frogger.x = Frogger.x + lane.speed * lane.direction * love.timer.getDelta()

                            -- Keep within bounds
                            if Frogger.x < 0 then Frogger.x = 0 end
                            if Frogger.x + Frogger.width > Constants.GAME_WIDTH then
                                Frogger.x = Constants.GAME_WIDTH -
                                    Frogger.width
                            end
                        end
                    end
                end
            end
        end


        -- check alla fine di tutti gli altri per lane e non per ogni ostacolo altrimenti si resetta più volte e sbarella
        if lane.type == 'water' and index == Frogger.gridY and not isOnAnyPlatform and not Frogger.isHopping then
            print("Game Over! Drowned at lane " .. index)
            Frogger:resetPosition()
        end
    end
end

return Lanes

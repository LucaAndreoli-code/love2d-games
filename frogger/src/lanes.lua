local Constants = require("src.constants")
local Frogger = require("src.frogger")
local Debug = require("src.debug")
local Points = require("src.points")
local Sprites = require("src.sprites")

local TileWidth = (Constants.GAME_WIDTH / Constants.GRID_WIDTH)
local ObstacleWidth = TileWidth - 5 --margine per hitbox
local isOnAnyPlatform = false
local LaneOffset = 50

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
            { x = 0,  type = 'car',   width = ObstacleWidth },
            { x = 45, type = 'truck', width = ObstacleWidth * 2 },
            { x = 90, type = 'car',   width = ObstacleWidth }
        }
    },
    {
        type = 'road',
        speed = 40,
        direction = -1,
        obstacles = {
            { x = 25, type = 'truck', width = ObstacleWidth * 2 },
            { x = 80, type = 'car',   width = ObstacleWidth },
        }
    },
    {
        type = 'road',
        speed = 20,
        direction = 1,
        obstacles = {
            { x = 0,   type = 'car', width = ObstacleWidth },
            { x = 75,  type = 'car', width = ObstacleWidth },
            { x = 125, type = 'car', width = ObstacleWidth }
        }
    },
    {
        type = 'road',
        speed = 80,
        direction = 1,
        obstacles = {
            { x = 0,  type = 'car', width = ObstacleWidth },
            { x = 75, type = 'car', width = ObstacleWidth }
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
            { x = 0,   type = 'log',       width = ObstacleWidth * 2 },
            { x = 100, type = 'crocodile', width = ObstacleWidth * 3 },
            { x = 50,  type = 'log',       width = ObstacleWidth * 3 },
        }
    },
    {
        type = 'water',
        speed = 15,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'turtle', width = ObstacleWidth },
            { x = 100, type = 'turtle', width = ObstacleWidth },
        }
    },
    {
        type = 'water',
        speed = 35,
        direction = 1,
        obstacles = {
            { x = 0,   type = 'log', width = ObstacleWidth * 2 },
            { x = 125, type = 'log', width = ObstacleWidth * 3 }
        }
    },
    {
        type = 'water',
        speed = 40,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'log', width = ObstacleWidth * 2 },
            { x = 125, type = 'log', width = ObstacleWidth * 2 }
        }
    },
    {
        type = 'water',
        speed = 30,
        direction = -1,
        obstacles = {
            { x = 0,   type = 'turtle', width = ObstacleWidth },
            { x = 125, type = 'log',    width = ObstacleWidth * 2 },
            { x = 200, type = 'turtle', width = ObstacleWidth }
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

            if (lane.type == 'end') then
                -- SALVARE POSIZIONE LILIPADS IN UNA TABELLA PER VERIFICARE VITTORIA
                -- VERIFICARE SE RANA COLPISCE NINFEA E AGGIUNGERE PUNTI
                -- DISEGNARE NINFEA
                -- SALVARE STATO DELLA PARTITA (NINFEA OCCUPATA O LIBERA)
                -- Add lilypad obstacle and save its position
                if not lane.obstacles[i] then
                    lane.obstacles[i] = {
                        x = x,
                        type = 'lilypad',
                        width = TileWidth,
                        occupied = false
                    }
                end
                if (Debug.enabled) then
                    love.graphics.rectangle('line', x, laneY, TileWidth, LaneHeight)
                end
                if lane.obstacles[i].occupied then
                    love.graphics.draw(
                        GameSprites.sheet,
                        GameSprites.quads.frog_on_lilypad,
                        x + 8,
                        laneY + 8,
                        0,
                        1, 1,
                        8, 8
                    )
                end
            end

            love.graphics.rectangle('fill', x, laneY, TileWidth, LaneHeight)
        end
    end
end

function Lanes:drawObstacles()
    for index = #Lanes, 1, -1 do
        local lane = Lanes[index]
        local laneY = (index - 1) * LaneHeight
        isOnAnyPlatform = false

        for _, obstacle in ipairs(lane.obstacles) do
            -- Update obstacle position
            obstacle.x = obstacle.x + lane.speed * lane.direction * love.timer.getDelta()

            -- Wrap around logic (aggiunto offset per evitare spawn istantanei)
            if lane.direction == 1 and obstacle.x > Constants.GAME_WIDTH then
                obstacle.x = -TileWidth * 3 - LaneOffset
            elseif lane.direction == -1 and obstacle.x < -TileWidth * 3 then
                obstacle.x = Constants.GAME_WIDTH + LaneOffset
            end

            local direction = 0
            if (lane.direction == 1) then
                direction = -math.pi
            end

            love.graphics.setColor(1, 1, 1, 1)

            Sprites:drawObstacles(obstacle, ObstacleWidth, lane, laneY, direction)

            local obstacleXOffset = obstacle.x + 2 -- Adjust for better hitbox
            if (Debug.enabled) then
                love.graphics.rectangle('line', obstacleXOffset, laneY, obstacle.width, LaneHeight)
                love.graphics.print(obstacle.type, obstacleXOffset + 5, laneY + 5)
            end

            CheckFroggerOnLane(obstacle, lane, laneY)
        end

        CheckFroggerNotOnPlatform(lane, index)
    end
end

-- Verify if Frogger is on an obstacle in the lanes
function CheckFroggerOnLane(obstacle, lane, laneY)
    if not Frogger.isHopping then
        local tempObstacle = obstacle
        tempObstacle.x = obstacle.x
        if Frogger:isOnPlatform(tempObstacle, laneY) then
            if lane.type == 'road' then -- Hit by obstacle
                -- Hit by vehicle
                if obstacle.type == 'car' or obstacle.type == 'truck' then
                    print("Game Over! Hit by vehicle")
                    if (Debug.enabled) then
                        return
                    end
                    Frogger:resetPosition()
                end
            elseif lane.type == 'water' then -- Moving on platform
                isOnAnyPlatform = true

                if obstacle.type == 'crocodile' then
                    print("Game Over! Eaten by crocodile")
                    if (Debug.enabled) then
                        return
                    end
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

-- Verify if Frogger is not on any platform in water lanes
function CheckFroggerNotOnPlatform(lane, index)
    if lane.type == 'water' and index == Frogger.gridY and not isOnAnyPlatform and not Frogger.isHopping then
        print("Game Over! Drowned at lane " .. index)
        Points:loseLife()
        if (Debug.enabled) then
            return
        end
        Frogger:resetPosition()
    end

    if Frogger:reachedEnd() and not Frogger.isHopping then
        for i, lilypad in ipairs(Lanes[1].obstacles) do
            if Frogger:isOnPlatform(lilypad, 1) and not lilypad.occupied then
                print("You reached a lilypad!")
                Points:add(100)
                lilypad.occupied = true
                Frogger:resetPosition()
                return
            end
        end
    end
end

return Lanes

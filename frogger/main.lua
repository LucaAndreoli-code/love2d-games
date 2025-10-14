function love.resize(w, h)
    W = w
    H = h
    LaneHeight = H / GRID_HEIGHT
    TileWidth = W / GRID_WIDTH
end

function love.load()
    -- Constants
    GRID_WIDTH = 13  -- numero di colonne
    GRID_HEIGHT = 12 -- numero di righe (corsie)
    NUM_LILIPAD = 6  -- numero di ninfee nella corsia finale

    W, H = love.graphics.getDimensions()
    LaneHeight = H / GRID_HEIGHT
    TileWidth = W / GRID_WIDTH

    -- Lane structure example:
    -- {
    --     type = 'safe' | 'road' | 'water',
    --     speed = 0,
    --     direction = 0,
    --     obstacles = {
    --         {x = 0, type = 'car'}
    --     },
    -- }


    Lanes = {
        {
            type = 'end',
            speed = 0,
            direction = 0,
            obstacles = {}
        },
        {
            type = 'road',
            speed = 100,
            direction = 1,
            obstacles = {
                { x = 0,   type = 'car' },
                { x = 300, type = 'car' },
                { x = 600, type = 'car' }
            }
        },
        {
            type = 'road',
            speed = 200,
            direction = 1,
            obstacles = {
                { x = 0,   type = 'car' },
                { x = 350, type = 'truck' },
                { x = 600, type = 'car' }
            }
        },
        {
            type = 'road',
            speed = 150,
            direction = -1,
            obstacles = {
                { x = 150, type = 'truck' },
                { x = 600, type = 'car' },
            }
        },
        {
            type = 'road',
            speed = 100,
            direction = 1,
            obstacles = {
                { x = 0,   type = 'car' },
                { x = 300, type = 'car' },
                { x = 600, type = 'car' }
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
            speed = 80,
            direction = 1,
            obstacles = {
                { x = 0,   type = 'log' },
                { x = 400, type = 'log' },
                { x = 800, type = 'crocodile' }
            }
        },
        {
            type = 'water',
            speed = 120,
            direction = -1,
            obstacles = {
                { x = 200, type = 'turtle' },
                { x = 600, type = 'turtle' }
            }
        },
        {
            type = 'water',
            speed = 80,
            direction = 1,
            obstacles = {
                { x = 0,   type = 'log' },
                { x = 400, type = 'log' }
            }
        },
        {
            type = 'water',
            speed = 80,
            direction = -1,
            obstacles = {
                { x = 0,   type = 'log' },
                { x = 400, type = 'log' }
            }
        },
        {
            type = 'water',
            speed = 120,
            direction = -1,
            obstacles = {
                { x = 200, type = 'turtle' },
                { x = 600, type = 'turtle' }
            }
        },
        {
            type = 'safe',
            speed = 0,
            direction = 0,
            obstacles = {}
        }
    }

    Frogger = {
        x = TileWidth * math.floor(GRID_WIDTH / 2),
        y = (GRID_HEIGHT - 1) * LaneHeight,
        width = TileWidth,
        height = LaneHeight,
        isOnPlatform = function(self, obstacle, laneY)
            return self.x < obstacle.x + TileWidth and
                self.x + self.width > obstacle.x and
                self.y < laneY + LaneHeight and
                self.y + self.height > laneY
        end
    }

    love.window.setTitle("Frogger")
end

function love.draw()
    DrawLanes()
    DrawObstacles()
    DrawFrogger()
end

function love.update(dt)
    -- Update logic can be added here if needed
end

function DrawFrogger()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', Frogger.x, Frogger.y, Frogger.width, Frogger.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Frogger", Frogger.x + 5, Frogger.y + 5)
end

function DrawObstacles()
    for index = #Lanes, 1, -1 do
        local lane = Lanes[index]
        local laneY = (index - 1) * LaneHeight

        for _, obstacle in ipairs(lane.obstacles) do
            -- Update obstacle position
            obstacle.x = obstacle.x + lane.speed * lane.direction * love.timer.getDelta()

            -- Wrap around logic
            if lane.direction == 1 and obstacle.x > W then
                obstacle.x = -TileWidth
            elseif lane.direction == -1 and obstacle.x < -TileWidth then
                obstacle.x = W
            end

            -- Draw obstacle
            if obstacle.type == 'car' then
                love.graphics.setColor(1, 0, 0, 1)
            elseif obstacle.type == 'truck' then
                love.graphics.setColor(0.5, 0.25, 0, 1)
            elseif obstacle.type == 'log' then
                love.graphics.setColor(0.55, 0.27, 0.07, 1)
            elseif obstacle.type == 'turtle' then
                love.graphics.setColor(0, 1, 0, 1)
            elseif obstacle.type == 'crocodile' then
                love.graphics.setColor(0, 0.5, 0, 1)
            else
                love.graphics.setColor(1, 1, 1, 1) -- default
            end

            love.graphics.rectangle('fill', obstacle.x, laneY, TileWidth, LaneHeight)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(obstacle.type, obstacle.x + 5, laneY + 5)

            if (Frogger:isOnPlatform(obstacle, laneY)) then
                if lane.type == 'road' or obstacle.type == 'crocodile' then
                    print("Game Over!")
                else
                    print("Continua")
                end
                Frogger.x = Frogger.x + lane.speed * lane.direction * love.timer.getDelta() -- move with platform
            end
        end
    end
end

function DrawLanes()
    for index = #Lanes, 1, -1 do
        local lane = Lanes[index]
        local laneY = (index - 1) * LaneHeight

        -- Draw lane border
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('line', 0, laneY, W, LaneHeight)
        love.graphics.print(index .. ': ' .. lane.type, 10, laneY + 10)

        -- Draw lane tiles
        DrawLaneTiles(lane, index, laneY)
    end
end

function DrawLaneTiles(lane, laneIndex, laneY)
    local numTiles = (lane.type == 'end') and NUM_LILIPAD or GRID_WIDTH
    local useSpacing = (lane.type == 'end')

    -- Calculate gap once
    local gapSize = 0
    if useSpacing then
        local totalTilesWidth = numTiles * TileWidth
        local remainingSpace = W - totalTilesWidth
        gapSize = remainingSpace / (numTiles - 1)
    end

    -- Draw tiles
    for i = 1, numTiles do
        -- Set color based on lane type
        if (lane.type == 'road') then
            love.graphics.setColor(1, 0, 0, 0.3)
        elseif (lane.type == 'water') then
            love.graphics.setColor(0, 0, 1, 0.3)
        else
            love.graphics.setColor(0, 1, 0, 0.3)
        end
        local x = (i - 1) * (TileWidth + gapSize)
        love.graphics.rectangle('fill', x, laneY, TileWidth, LaneHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(laneIndex .. ": " .. i, x, laneY + 30)
    end
end

function love.keypressed(key)
    if key == 'up' then
        if Frogger.y - LaneHeight >= 0 then
            Frogger.y = Frogger.y - LaneHeight
        end
    elseif key == 'down' then
        if Frogger.y + LaneHeight < H then
            Frogger.y = Frogger.y + LaneHeight
        end
    elseif key == 'left' then
        if Frogger.x - TileWidth >= 0 then
            Frogger.x = Frogger.x - TileWidth
        end
    elseif key == 'right' then
        if Frogger.x + TileWidth < W then
            Frogger.x = Frogger.x + TileWidth
        end
    end
end

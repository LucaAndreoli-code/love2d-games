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
            type = 'safe',
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

                { x = 450, type = 'truck' },
                { x = 600, type = 'car' }
            }
        },
        {
            type = 'road',
            speed = 150,
            direction = -1,
            obstacles = {
                { x = 150, type = 'truck' },
                { x = 300, type = 'car' },
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



    love.window.setTitle("Frogger")
end

function love.draw()
    DrawLanes()
end

-- function GenerateLanes()
--     W, H = love.graphics.getDimensions()
--     LaneHeight = H / #Lanes
--     LanePositionsWidth = W / #Lanes

--     for key, value in pairs(Lanes) do
--         love.graphics.print(key .. ': ' .. value.type, 10, (key - 1) * LaneHeight + 10)
--         love.graphics.rectangle('line', 0, (key - 1) * LaneHeight, W, LaneHeight)

--         local blocks = 0
--         local spacing = true
--         if (value.type ~= 'safe') then
--             blocks = #Lanes
--             spacing = false
--             love.graphics.setColor(0, 0, 1, 0.3)
--         else
--             blocks = 6
--             spacing = true
--             love.graphics.setColor(0, 1, 0, 0.3)
--         end

--         local gapSize = 0
--         for i = 1, blocks do
--             if spacing then
--                 local totalTilesWidth = blocks * LanePositionsWidth
--                 local remainingSpace = W - totalTilesWidth
--                 gapSize = remainingSpace / (blocks - 1)
--             else
--                 gapSize = 0
--             end
--             local x = (i - 1) * (LanePositionsWidth + gapSize)
--             love.graphics.print(key .. ": " .. i, x, (key - 1) * LaneHeight + 30)
--             love.graphics.rectangle('fill', x, (key - 1) * LaneHeight,
--                 LanePositionsWidth,
--                 LaneHeight)
--         end
--     end
-- end

function love.update(dt)
    -- Game update logic goes here
end

function DrawLanes()
    for index, lane in ipairs(Lanes) do
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
    local numTiles = (lane.type == 'safe') and 6 or GRID_WIDTH
    local useSpacing = (lane.type == 'safe')

    -- Calculate gap once
    local gapSize = 0
    if useSpacing then
        local totalTilesWidth = numTiles * TileWidth
        local remainingSpace = W - totalTilesWidth
        gapSize = remainingSpace / (numTiles - 1)
    end

    -- Set color based on lane type
    if lane.type == 'safe' then
        love.graphics.setColor(0, 1, 0, 0.3)
    else
        love.graphics.setColor(0, 0, 1, 0.3)
    end

    -- Draw tiles
    for i = 1, numTiles do
        local x = (i - 1) * (TileWidth + gapSize)
        love.graphics.rectangle('fill', x, laneY, TileWidth, LaneHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(laneIndex .. ": " .. i, x, laneY + 30)

        -- Reset color for next tile
        if lane.type == 'safe' then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0, 0, 1, 0.3)
        end
    end
end

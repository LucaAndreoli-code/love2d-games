local Constants = require("src.constants")

local GameCanvas = {}
local canvas = nil

function GameCanvas:load()
    -- Crea il canvas virtuale
    canvas = love.graphics.newCanvas(Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
    canvas:setFilter("nearest", "nearest") -- mantieni pixel sharp

    -- Ora usa GAME_WIDTH e GAME_HEIGHT per calcolare le dimensioni dei tile
    TileWidth = Constants.GAME_WIDTH / 13   -- = 16
    LaneHeight = Constants.GAME_HEIGHT / 12 -- = 16
end

function GameCanvas:setCanvas()
    if not canvas then
        error("Canvas not initialized. Call GameCanvas:load() first.")
    end
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
end

function GameCanvas:setWindow()
    love.graphics.setCanvas() -- torna allo schermo

    -- Calcola lo scaling per adattare il canvas alla finestra
    local windowW, windowH = love.graphics.getDimensions()
    local scaleX = windowW / Constants.GAME_WIDTH
    local scaleY = windowH / Constants.GAME_HEIGHT
    local scale = math.min(scaleX, scaleY) -- mantieni aspect ratio

    -- Centra il canvas scalato
    local offsetX = (windowW - Constants.GAME_WIDTH * scale) / 2
    local offsetY = (windowH - Constants.GAME_HEIGHT * scale) / 2

    -- Disegna il canvas scalato
    if not canvas then
        error("Canvas not initialized. Call GameCanvas:load() first.")
    end
    love.graphics.draw(canvas, offsetX, offsetY, 0, scale, scale)
end

function GameCanvas:getWidth()
    return Constants.GAME_WIDTH
end

function GameCanvas:getHeight()
    return Constants.GAME_HEIGHT
end

return GameCanvas

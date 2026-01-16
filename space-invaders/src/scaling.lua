local scaling = {}

local GAME_WIDTH = 800
local GAME_HEIGHT = 600

scaling.scale = 1
scaling.offsetX = 0
scaling.offsetY = 0
scaling.GAME_WIDTH = GAME_WIDTH
scaling.GAME_HEIGHT = GAME_HEIGHT

function scaling.update(windowWidth, windowHeight)
    local scaleX = windowWidth / scaling.GAME_WIDTH
    local scaleY = windowHeight / scaling.GAME_HEIGHT
    scaling.scale = math.min(scaleX, scaleY)
    scaling.offsetX = (windowWidth - scaling.GAME_WIDTH * scaling.scale) / 2
    scaling.offsetY = (windowHeight - scaling.GAME_HEIGHT * scaling.scale) / 2
end

function scaling.toGame(windowX, windowY)
    local gameX = (windowX - scaling.offsetX) / scaling.scale
    local gameY = (windowY - scaling.offsetY) / scaling.scale
    -- Clamp to canvas bounds
    gameX = math.max(0, math.min(scaling.GAME_WIDTH, gameX))
    gameY = math.max(0, math.min(scaling.GAME_HEIGHT, gameY))
    return gameX, gameY
end

return scaling

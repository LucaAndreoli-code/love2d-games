local Sprites = {}

function Sprites.load()
    local spritesheet = love.graphics.newImage("resources/sprite/frogger.png")
    spritesheet:setFilter("nearest", "nearest")

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

    -- TODO newQuad all the sprites

    return { sheet = spritesheet, quads = sprites }
end

return Sprites

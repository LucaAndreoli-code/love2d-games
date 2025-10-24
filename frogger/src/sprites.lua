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

    local crocodilePosX = 41
    local crocodilePosY = 134

    sprites.crocodile = love.graphics.newQuad(
        (crocodilePosX + px16 * 4), crocodilePosY,
        px16 * 3, px16,
        spritesheet:getDimensions()
    )

    -- TODO newQuad all the sprites

    return { sheet = spritesheet, quads = sprites }
end

return Sprites

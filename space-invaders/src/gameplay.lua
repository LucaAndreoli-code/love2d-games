local gameplay = {}
local hud = require("src.hud")
local scaling = require("src.scaling")

local MARGIN = 50
local GRID_SIZE = 16
local SHIP_SCALE = 3

local colors = {
    { r = 1, g = 0,   b = 0 },
    { r = 0, g = 0.2, b = 0.6 },
    { r = 0, g = 0,   b = 0 },
    { r = 1, g = 1,   b = 1 }
}

local player = {
    x = 0,
    y = 0,
    speed = 200,
    shipCanvas = nil,
    firingPoint = { offsetX = 0, offsetY = 0 },
    fireCooldown = 0.40,
    lastFired = 0
}

local bullets = {}
local BULLET_SPEED = 400
local BULLET_WIDTH = 4
local BULLET_HEIGHT = 10

local shipData = nil

local function createShipCanvas(grid)
    local canvas = love.graphics.newCanvas(GRID_SIZE * SHIP_SCALE, GRID_SIZE * SHIP_SCALE)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    for y = 1, GRID_SIZE do
        for x = 1, GRID_SIZE do
            if grid[y] and grid[y][x] then
                local colorIndex = grid[y][x]
                local color = colors[colorIndex]
                love.graphics.setColor(color.r, color.g, color.b)
                love.graphics.rectangle("fill",
                    (x - 1) * SHIP_SCALE,
                    (y - 1) * SHIP_SCALE,
                    SHIP_SCALE,
                    SHIP_SCALE
                )
            end
        end
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)

    return canvas
end

function gameplay.load(data)
    hud.load()

    shipData = data

    player.shipCanvas = createShipCanvas(data.grid)

    local shipWidth = GRID_SIZE * SHIP_SCALE
    local shipHeight = GRID_SIZE * SHIP_SCALE

    player.x = (scaling.GAME_WIDTH - shipWidth) / 2
    player.y = scaling.GAME_HEIGHT - MARGIN - shipHeight - 20

    if data.firingPoint then
        player.firingPoint.offsetX = (data.firingPoint.x - 1) * SHIP_SCALE + SHIP_SCALE / 2
        player.firingPoint.offsetY = (data.firingPoint.y - 1) * SHIP_SCALE
    else
        player.firingPoint.offsetX = shipWidth / 2
        player.firingPoint.offsetY = 0
    end

    player.lastFired = 0
    bullets = {}
end

function gameplay.update(dt)
    local shipWidth = GRID_SIZE * SHIP_SCALE
    local shipHeight = GRID_SIZE * SHIP_SCALE

    local dx, dy = 0, 0

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dy = -1
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dy = 1
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dx = -1
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dx = 1
    end

    if dx ~= 0 and dy ~= 0 then
        local diag = 1 / math.sqrt(2)
        dx = dx * diag
        dy = dy * diag
    end

    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt

    local minX = MARGIN
    local maxX = scaling.GAME_WIDTH - MARGIN - shipWidth
    local minY = MARGIN
    local maxY = scaling.GAME_HEIGHT - MARGIN - shipHeight

    player.x = math.max(minX, math.min(maxX, player.x))
    player.y = math.max(minY, math.min(maxY, player.y))

    player.lastFired = player.lastFired + dt

    if love.keyboard.isDown("space") and player.lastFired >= player.fireCooldown then
        local bulletX = player.x + player.firingPoint.offsetX - BULLET_WIDTH / 2
        local bulletY = player.y + player.firingPoint.offsetY - BULLET_HEIGHT

        table.insert(bullets, {
            x = bulletX,
            y = bulletY,
            speed = BULLET_SPEED
        })

        player.lastFired = 0
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - bullet.speed * dt

        if bullet.y + BULLET_HEIGHT < 0 then
            table.remove(bullets, i)
        end
    end
end

function gameplay.draw()
    love.graphics.setColor(0, 1, 0)
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, BULLET_WIDTH, BULLET_HEIGHT)
    end

    love.graphics.setColor(1, 1, 1)
    if player.shipCanvas then
        love.graphics.draw(player.shipCanvas, player.x, player.y)
    end

    hud.draw()
end

function gameplay.getPlayer()
    return player
end

function gameplay.getBullets()
    return bullets
end

return gameplay

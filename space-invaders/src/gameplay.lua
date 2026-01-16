local gameplay = {}
local hud = require("src.hud")
local scaling = require("src.scaling")
local colors = require("src.constants.colors")
local gameConst = require("src.constants.game")

local player = {
    x = 0,
    y = 0,
    speed = gameConst.PLAYER_SPEED,
    shipCanvas = nil,
    firingPoint = { offsetX = 0, offsetY = 0 },
    fireCooldown = gameConst.FIRE_COOLDOWN,
    lastFired = 0
}

local bullets = {}
local shipData = nil

local function createShipCanvas(grid)
    local gridSize = gameConst.GRID_SIZE
    local shipScale = gameConst.SHIP_SCALE
    local canvas = love.graphics.newCanvas(gridSize * shipScale, gridSize * shipScale)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    for y = 1, gridSize do
        for x = 1, gridSize do
            if grid[y] and grid[y][x] then
                local colorIndex = grid[y][x]
                local color = colors.SHIP_PALETTE[colorIndex]
                love.graphics.setColor(color.r, color.g, color.b)
                love.graphics.rectangle("fill",
                    (x - 1) * shipScale,
                    (y - 1) * shipScale,
                    shipScale,
                    shipScale
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

    local shipScale = gameConst.SHIP_SCALE
    local shipWidth = gameConst.GRID_SIZE * shipScale
    local shipHeight = gameConst.GRID_SIZE * shipScale

    player.x = (scaling.GAME_WIDTH - shipWidth) / 2
    player.y = scaling.GAME_HEIGHT - gameConst.GAMEPLAY_MARGIN - shipHeight - 20

    if data.firingPoint then
        player.firingPoint.offsetX = (data.firingPoint.x - 1) * shipScale + shipScale / 2
        player.firingPoint.offsetY = (data.firingPoint.y - 1) * shipScale
    else
        player.firingPoint.offsetX = shipWidth / 2
        player.firingPoint.offsetY = 0
    end

    player.lastFired = 0
    bullets = {}
end

function gameplay.update(dt)
    local shipWidth = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local shipHeight = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local margin = gameConst.GAMEPLAY_MARGIN

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

    local minX = margin
    local maxX = scaling.GAME_WIDTH - margin - shipWidth
    local minY = margin
    local maxY = scaling.GAME_HEIGHT - margin - shipHeight

    player.x = math.max(minX, math.min(maxX, player.x))
    player.y = math.max(minY, math.min(maxY, player.y))

    player.lastFired = player.lastFired + dt

    if love.keyboard.isDown("space") and player.lastFired >= player.fireCooldown then
        local bulletX = player.x + player.firingPoint.offsetX - gameConst.BULLET_WIDTH / 2
        local bulletY = player.y + player.firingPoint.offsetY - gameConst.BULLET_HEIGHT

        table.insert(bullets, {
            x = bulletX,
            y = bulletY,
            speed = gameConst.BULLET_SPEED
        })

        player.lastFired = 0
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - bullet.speed * dt

        if bullet.y + gameConst.BULLET_HEIGHT < 0 then
            table.remove(bullets, i)
        end
    end
end

function gameplay.draw()
    love.graphics.setColor(colors.GREEN)
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, gameConst.BULLET_WIDTH, gameConst.BULLET_HEIGHT)
    end

    love.graphics.setColor(colors.WHITE)
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

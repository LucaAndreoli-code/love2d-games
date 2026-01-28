local gameplay = {}
local hud = require("src.hud")
local scaling = require("src.scaling")
local colors = require("src.constants.colors")
local gameConst = require("src.constants.game")
local fontsConst = require("src.constants.fonts")

-- Player state
local player = {
    x = 0,
    y = 0,
    speed = gameConst.PLAYER_SPEED,
    shipCanvas = nil,
    firingPoint = { offsetX = 0, offsetY = 0 },
    fireCooldown = gameConst.FIRE_COOLDOWN,
    lastFired = 0,
    lives = gameConst.PLAYER_LIVES,
    invincible = false,
    invincibleTimer = 0
}

-- Game entities
local bullets = {}
local enemies = {}
local shipData = nil

-- Wave system
local wave = {
    current = 1,
    enemyCount = gameConst.WAVE_BASE_ENEMIES,
    speedMultiplier = 1.0,
    delayTimer = 0,
    waitingForNext = false
}

-- Game state
local gameState = "playing" -- "playing", "gameover"
local score = 0
local gameOverFont = nil

-- Enemy sprite
local enemySprite = nil
local enemySpriteScale = 2

-- Enemy formation (Space Invaders style)
local formation = {
    direction = 1,           -- 1 = right, -1 = left
    speed = gameConst.ENEMY_BASE_SPEED,
    dropDistance = 20,       -- How far enemies drop when hitting edge
    edgeMargin = 50          -- Distance from screen edge before turning
}

-- AABB collision detection
local function checkCollision(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and
        ax + aw > bx and
        ay < by + bh and
        ay + ah > by
end

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

-- Get actual enemy size with scale applied
local function getEnemySize()
    return gameConst.ENEMY_SIZE * enemySpriteScale
end

local function spawnWave()
    local size = getEnemySize()
    local cols = 11  -- Classic Space Invaders has 11 columns
    local rows = 5   -- and 5 rows

    -- Adjust rows based on wave (more enemies as waves progress)
    rows = math.min(5 + math.floor((wave.current - 1) / 2), 7)

    local spacingX = size + 12
    local spacingY = size + 8

    -- Calculate formation width and center it
    local formationWidth = cols * spacingX
    local startX = (scaling.GAME_WIDTH - formationWidth) / 2
    local startY = 80

    for row = 1, rows do
        for col = 1, cols do
            local x = startX + (col - 1) * spacingX
            local y = startY + (row - 1) * spacingY

            table.insert(enemies, {
                x = x,
                y = y,
                width = size,
                height = size,
                health = gameConst.ENEMY_HEALTH,
                row = row,
                col = col
            })
        end
    end

    -- Reset formation direction and set speed based on wave
    formation.direction = 1
    formation.speed = gameConst.ENEMY_BASE_SPEED * wave.speedMultiplier

    wave.waitingForNext = false
end

local function respawnPlayer()
    local shipWidth = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local shipHeight = gameConst.GRID_SIZE * gameConst.SHIP_SCALE

    player.x = gameConst.RESPAWN_X - shipWidth / 2
    player.y = gameConst.RESPAWN_Y - shipHeight / 2
    player.invincible = true
    player.invincibleTimer = gameConst.INVINCIBILITY_TIME
end

local function resetGame()
    -- Reset player
    player.lives = gameConst.PLAYER_LIVES
    player.invincible = false
    player.invincibleTimer = 0
    player.lastFired = 0

    -- Reset position
    local shipWidth = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local shipHeight = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    player.x = (scaling.GAME_WIDTH - shipWidth) / 2
    player.y = scaling.GAME_HEIGHT - gameConst.GAMEPLAY_MARGIN - shipHeight - 20

    -- Reset game entities
    bullets = {}
    enemies = {}

    -- Reset wave
    wave.current = 1
    wave.enemyCount = gameConst.WAVE_BASE_ENEMIES
    wave.speedMultiplier = 1.0
    wave.delayTimer = 0
    wave.waitingForNext = false

    -- Reset formation
    formation.direction = 1
    formation.speed = gameConst.ENEMY_BASE_SPEED

    -- Reset score and HUD
    score = 0
    hud.setLives(player.lives)
    hud.setScore(score)

    -- Spawn first wave
    spawnWave()

    gameState = "playing"
end

function gameplay.load(data)
    hud.load()
    gameOverFont = love.graphics.newFont(fontsConst.PATH, fontsConst.SIZE_XL)

    -- Load enemy sprite
    enemySprite = love.graphics.newImage("assets/sprites/enemy.png")
    enemySprite:setFilter("nearest", "nearest") -- Pixel-perfect scaling
    -- Scale is set to 2x at module level (enemySpriteScale = 2)

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

    -- Initialize game state
    player.lives = gameConst.PLAYER_LIVES
    player.invincible = false
    player.invincibleTimer = 0
    player.lastFired = 0

    bullets = {}
    enemies = {}
    score = 0

    wave.current = 1
    wave.enemyCount = gameConst.WAVE_BASE_ENEMIES
    wave.speedMultiplier = 1.0
    wave.delayTimer = 0
    wave.waitingForNext = false

    -- Initialize HUD
    hud.setLives(player.lives)
    hud.setScore(score)

    -- Spawn first wave
    spawnWave()

    gameState = "playing"
end

local function updatePlayer(dt)
    local shipWidth = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local shipHeight = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local margin = gameConst.GAMEPLAY_MARGIN

    -- Invincibility timer
    if player.invincible then
        player.invincibleTimer = player.invincibleTimer - dt
        if player.invincibleTimer <= 0 then
            player.invincible = false
            player.invincibleTimer = 0
        end
    end

    -- Movement
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

    -- Shooting
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
end

local function updateBullets(dt)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - bullet.speed * dt

        if bullet.y + gameConst.BULLET_HEIGHT < 0 then
            table.remove(bullets, i)
        end
    end
end

local function updateEnemies(dt)
    if #enemies == 0 then return end

    -- Classic Space Invaders movement: all enemies move together
    -- Check if any enemy hits the edge
    local hitEdge = false
    local size = getEnemySize()

    for _, enemy in ipairs(enemies) do
        if formation.direction == 1 then
            -- Moving right, check right edge
            if enemy.x + size >= scaling.GAME_WIDTH - formation.edgeMargin then
                hitEdge = true
                break
            end
        else
            -- Moving left, check left edge
            if enemy.x <= formation.edgeMargin then
                hitEdge = true
                break
            end
        end
    end

    -- If hit edge, drop down and change direction
    if hitEdge then
        formation.direction = formation.direction * -1
        for _, enemy in ipairs(enemies) do
            enemy.y = enemy.y + formation.dropDistance
        end

        -- Speed up slightly when changing direction (classic behavior)
        formation.speed = formation.speed * 1.02
    end

    -- Move all enemies horizontally
    local moveX = formation.direction * formation.speed * dt
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x + moveX

        -- Check if enemies reached the bottom (game over condition in classic)
        if enemy.y + size >= scaling.GAME_HEIGHT - 100 then
            -- Enemies reached player zone - lose a life
            player.lives = player.lives - 1
            hud.setLives(player.lives)

            if player.lives <= 0 then
                gameState = "gameover"
            else
                -- Clear enemies and spawn new wave
                enemies = {}
                wave.waitingForNext = true
                wave.delayTimer = gameConst.WAVE_DELAY
            end
            return
        end
    end
end

local function checkBulletEnemyCollisions()
    local initialEnemyCount = #enemies

    for bi = #bullets, 1, -1 do
        local bullet = bullets[bi]

        for ei = #enemies, 1, -1 do
            local enemy = enemies[ei]

            if checkCollision(
                    bullet.x, bullet.y, gameConst.BULLET_WIDTH, gameConst.BULLET_HEIGHT,
                    enemy.x, enemy.y, enemy.width, enemy.height
                ) then
                -- Hit enemy
                enemy.health = enemy.health - 1
                table.remove(bullets, bi)

                -- Check if enemy dead
                if enemy.health <= 0 then
                    table.remove(enemies, ei)
                    score = score + gameConst.ENEMY_KILL_SCORE
                    hud.setScore(score)

                    -- Classic Space Invaders: speed up as enemies die
                    if #enemies > 0 then
                        local speedBoost = 1 + (initialEnemyCount - #enemies) * 0.01
                        formation.speed = formation.speed * speedBoost
                    end
                end

                break
            end
        end
    end
end

local function checkPlayerEnemyCollisions()
    if player.invincible then return end

    local shipWidth = gameConst.GRID_SIZE * gameConst.SHIP_SCALE
    local shipHeight = gameConst.GRID_SIZE * gameConst.SHIP_SCALE

    for i = #enemies, 1, -1 do
        local enemy = enemies[i]

        if checkCollision(
                player.x, player.y, shipWidth, shipHeight,
                enemy.x, enemy.y, enemy.width, enemy.height
            ) then
            -- Player hit
            table.remove(enemies, i)
            player.lives = player.lives - 1
            hud.setLives(player.lives)

            if player.lives <= 0 then
                gameState = "gameover"
            else
                respawnPlayer()
            end

            break
        end
    end
end

local function updateWaveSystem(dt)
    if #enemies == 0 then
        if not wave.waitingForNext then
            wave.waitingForNext = true
            wave.delayTimer = gameConst.WAVE_DELAY
        else
            wave.delayTimer = wave.delayTimer - dt
            if wave.delayTimer <= 0 then
                -- Next wave
                wave.current = wave.current + 1
                wave.enemyCount = gameConst.WAVE_BASE_ENEMIES + (wave.current - 1) * gameConst.WAVE_ENEMIES_INCREMENT
                wave.speedMultiplier = wave.speedMultiplier * gameConst.WAVE_SPEED_MULTIPLIER
                spawnWave()
            end
        end
    end
end

function gameplay.update(dt)
    if gameState == "gameover" then
        return
    end

    -- Update all systems
    updatePlayer(dt)
    updateBullets(dt)
    updateEnemies(dt)

    -- Collision detection
    checkBulletEnemyCollisions()
    checkPlayerEnemyCollisions()

    -- Wave management
    updateWaveSystem(dt)
end

function gameplay.draw()
    -- Draw bullets
    love.graphics.setColor(colors.GREEN)
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, gameConst.BULLET_WIDTH, gameConst.BULLET_HEIGHT)
    end

    -- Draw enemies
    love.graphics.setColor(colors.WHITE)
    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemySprite, enemy.x, enemy.y, 0, enemySpriteScale, enemySpriteScale)
    end

    -- Draw player (with blinking if invincible)
    if player.invincible then
        local alpha = math.abs(math.sin(player.invincibleTimer * 10))
        love.graphics.setColor(1, 1, 1, alpha)
    else
        love.graphics.setColor(colors.WHITE)
    end

    if player.shipCanvas then
        love.graphics.draw(player.shipCanvas, player.x, player.y)
    end

    -- Draw HUD
    love.graphics.setColor(colors.WHITE)
    hud.draw()

    -- Draw wave indicator
    love.graphics.setColor(colors.WHITE)
    love.graphics.setFont(gameOverFont)
    love.graphics.print("WAVE " .. wave.current, scaling.GAME_WIDTH - 150, scaling.GAME_HEIGHT - 40)

    -- Game over overlay
    if gameState == "gameover" then
        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, scaling.GAME_WIDTH, scaling.GAME_HEIGHT)

        -- Game over text
        love.graphics.setFont(gameOverFont)
        love.graphics.setColor(colors.WHITE)

        local gameOverText = "GAME OVER"
        local goWidth = gameOverFont:getWidth(gameOverText)
        love.graphics.print(gameOverText, (scaling.GAME_WIDTH - goWidth) / 2, scaling.GAME_HEIGHT / 2 - 60)

        local scoreText = "SCORE: " .. score
        local scoreWidth = gameOverFont:getWidth(scoreText)
        love.graphics.print(scoreText, (scaling.GAME_WIDTH - scoreWidth) / 2, scaling.GAME_HEIGHT / 2)

        local waveText = "WAVE: " .. wave.current
        local waveWidth = gameOverFont:getWidth(waveText)
        love.graphics.print(waveText, (scaling.GAME_WIDTH - waveWidth) / 2, scaling.GAME_HEIGHT / 2 + 50)

        love.graphics.setColor(colors.TEXT_HINT)
        local restartText = "ENTER = Restart | ESC = Menu"
        local restartWidth = gameOverFont:getWidth(restartText)
        love.graphics.print(restartText, (scaling.GAME_WIDTH - restartWidth) / 2, scaling.GAME_HEIGHT / 2 + 120)
    end
end

function gameplay.keypressed(key)
    if gameState == "gameover" then
        if key == "return" or key == "kpenter" then
            resetGame()
        elseif key == "escape" then
            return "menu"
        end
    end
    return nil
end

function gameplay.getPlayer()
    return player
end

function gameplay.getBullets()
    return bullets
end

function gameplay.getEnemies()
    return enemies
end

function gameplay.getState()
    return gameState
end

return gameplay

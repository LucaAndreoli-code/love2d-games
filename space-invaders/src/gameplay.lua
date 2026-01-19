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
local enemySpriteScale = 1

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

local function isOverlappingWithExisting(x, y, width, height, minDistance)
    for _, enemy in ipairs(enemies) do
        local dx = (x + width / 2) - (enemy.x + enemy.width / 2)
        local dy = (y + height / 2) - (enemy.y + enemy.height / 2)
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < minDistance then
            return true
        end
    end
    return false
end

local function spawnEnemy(rowOffset)
    local size = gameConst.ENEMY_SIZE
    local minDistance = size * 2.5 -- Minimum distance between enemies
    local maxAttempts = 20
    local x, y

    -- Try to find a non-overlapping position
    for _ = 1, maxAttempts do
        x = math.random(gameConst.ENEMY_SPAWN_MIN_X, gameConst.ENEMY_SPAWN_MAX_X)
        y = -size - rowOffset - math.random(0, 50)

        if not isOverlappingWithExisting(x, y, size, size, minDistance) then
            break
        end
    end

    -- Sinusoidal movement parameters
    local sineAmplitude = math.random(30, 80)      -- How far left/right it moves
    local sineFrequency = math.random(15, 35) / 10 -- How fast it oscillates (1.5 to 3.5)
    local sinePhase = math.random() * math.pi * 2  -- Random starting phase

    table.insert(enemies, {
        x = x,
        y = y,
        baseX = x, -- Store original X for sinusoidal calculation
        width = size,
        height = size,
        health = gameConst.ENEMY_HEALTH,
        speed = gameConst.ENEMY_BASE_SPEED * wave.speedMultiplier,
        -- Sinusoidal movement
        sineAmplitude = sineAmplitude,
        sineFrequency = sineFrequency,
        sinePhase = sinePhase,
        timeAlive = 0
    })
end

local function spawnWave()
    local rowSpacing = gameConst.ENEMY_SIZE * 3
    for i = 1, wave.enemyCount do
        local rowOffset = math.floor((i - 1) / 5) * rowSpacing -- 5 enemies per row
        spawnEnemy(rowOffset)
    end
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
    -- Calculate scale to match ENEMY_SIZE
    enemySpriteScale = (gameConst.ENEMY_SIZE / enemySprite:getWidth()) * 2

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
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]

        -- Update time alive for sinusoidal movement
        enemy.timeAlive = enemy.timeAlive + dt

        -- Vertical movement (descending)
        enemy.y = enemy.y + enemy.speed * dt

        -- Update base X position as enemy descends (for proper sine wave center)
        enemy.baseX = enemy.baseX or enemy.x

        -- Sinusoidal horizontal movement
        local sineOffset = enemy.sineAmplitude * math.sin(enemy.timeAlive * enemy.sineFrequency + enemy.sinePhase)
        enemy.x = enemy.baseX + sineOffset

        -- Clamp X to screen bounds
        enemy.x = math.max(gameConst.ENEMY_SPAWN_MIN_X, math.min(gameConst.ENEMY_SPAWN_MAX_X, enemy.x))

        -- Remove if off screen
        if enemy.y > scaling.GAME_HEIGHT then
            table.remove(enemies, i)
        end
    end
end

local function checkBulletEnemyCollisions()
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

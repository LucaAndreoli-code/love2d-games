local hud = {}

local GAME_WIDTH = 800
local GAME_HEIGHT = 600

-- HUD data
local data = {
    health = 3,
    maxHealth = 3,
    score = 0,
    coins = 0,
    powerups = {}
}

local fonts = {
    small = nil,
    medium = nil,
    large = nil
}

local function drawTextWithShadow(text, x, y, font, color, align)
    align = align or "left"

    love.graphics.setFont(font)

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.printf(text, x + 2, y + 2, GAME_WIDTH, align)

    -- Main text
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.printf(text, x, y, GAME_WIDTH, align)
end

function hud.load()
    -- Load fonts
    fonts.small = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 20)
    fonts.medium = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 28)
    fonts.large = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 36)
end

function hud.draw()
    local padding = 20

    -- ALTO SINISTRA - Vita
    local healthY = padding
    love.graphics.setFont(fonts.small)
    drawTextWithShadow("HP:", padding, healthY, fonts.small, {1, 1, 1})

    -- Barra vita
    local healthBarX = padding + fonts.small:getWidth("HP: ")
    local healthBarWidth = 120
    local healthBarHeight = 20
    local healthPercent = data.health / data.maxHealth

    -- Background barra
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", healthBarX, healthY + 2, healthBarWidth, healthBarHeight)

    -- Barra vita (verde -> giallo -> rosso in base alla vita)
    local r, g, b
    if healthPercent > 0.5 then
        r = 2 * (1 - healthPercent)
        g = 1
        b = 0
    else
        r = 1
        g = 2 * healthPercent
        b = 0
    end
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", healthBarX, healthY + 2, healthBarWidth * healthPercent, healthBarHeight)

    -- Bordo barra
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", healthBarX, healthY + 2, healthBarWidth, healthBarHeight)

    -- Testo vita numerica
    love.graphics.setFont(fonts.small)
    local healthText = data.health .. "/" .. data.maxHealth
    local healthTextX = healthBarX + (healthBarWidth - fonts.small:getWidth(healthText)) / 2
    drawTextWithShadow(healthText, healthTextX, healthY + 2, fonts.small, {1, 1, 1})

    -- ALTO CENTRO - Punti
    local scoreText = "SCORE: " .. data.score
    drawTextWithShadow(scoreText, 0, padding, fonts.large, {1, 1, 1}, "center")

    -- ALTO DESTRA - Coins
    local coinsText = "COINS: " .. data.coins
    local coinsTextWidth = fonts.medium:getWidth(coinsText)
    local coinsX = GAME_WIDTH - coinsTextWidth - padding
    drawTextWithShadow(coinsText, coinsX, padding + 5, fonts.medium, {1, 0.85, 0})

    -- BASSO CENTRO - Potenziamenti (placeholder slots)
    local powerupY = GAME_HEIGHT - padding - 40
    local slotSize = 40
    local slotSpacing = 10
    local numSlots = 4
    local totalWidth = numSlots * slotSize + (numSlots - 1) * slotSpacing
    local startX = (GAME_WIDTH - totalWidth) / 2

    for i = 1, numSlots do
        local slotX = startX + (i - 1) * (slotSize + slotSpacing)

        -- Slot background
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle("fill", slotX, powerupY, slotSize, slotSize, 5, 5)

        -- Slot border
        love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", slotX, powerupY, slotSize, slotSize, 5, 5)
        love.graphics.setLineWidth(1)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function hud.update(deltaHealth, deltaScore, deltaCoins)
    if deltaHealth then
        data.health = math.max(0, math.min(data.maxHealth, data.health + deltaHealth))
    end
    if deltaScore then
        data.score = data.score + deltaScore
    end
    if deltaCoins then
        data.coins = data.coins + deltaCoins
    end
end

function hud.getData()
    return data
end

return hud

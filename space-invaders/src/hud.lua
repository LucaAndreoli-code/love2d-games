local hud = {}
local scaling = require("src.scaling")
local colorsConst = require("src.constants.colors")
local fontsConst = require("src.constants.fonts")
local gameConst = require("src.constants.game")

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
    love.graphics.setColor(colorsConst.SHADOW)
    love.graphics.printf(text, x + 2, y + 2, scaling.GAME_WIDTH, align)

    -- Main text
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.printf(text, x, y, scaling.GAME_WIDTH, align)
end

function hud.load()
    -- Load fonts
    fonts.small = love.graphics.newFont(fontsConst.PATH, fontsConst.SIZE_TINY)
    fonts.medium = love.graphics.newFont(fontsConst.PATH, fontsConst.SIZE_SMALL)
    fonts.large = love.graphics.newFont(fontsConst.PATH, fontsConst.SIZE_LARGE)
end

function hud.draw()
    local padding = gameConst.UI_MARGIN
    local healthBarWidth = gameConst.HEALTH_BAR_WIDTH
    local healthBarHeight = gameConst.HEALTH_BAR_HEIGHT
    local slotSize = gameConst.POWERUP_SLOT_SIZE
    local numSlots = gameConst.POWERUP_SLOTS

    -- ALTO SINISTRA - Vita
    local healthY = padding
    love.graphics.setFont(fonts.small)
    drawTextWithShadow("HP:", padding, healthY, fonts.small, colorsConst.WHITE)

    -- Barra vita
    local healthBarX = padding + fonts.small:getWidth("HP: ")
    local healthPercent = data.health / data.maxHealth

    -- Background barra
    love.graphics.setColor(colorsConst.HEALTH_BAR_BG)
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
    love.graphics.setColor(colorsConst.WHITE)
    love.graphics.rectangle("line", healthBarX, healthY + 2, healthBarWidth, healthBarHeight)

    -- Testo vita numerica
    love.graphics.setFont(fonts.small)
    local healthText = data.health .. "/" .. data.maxHealth
    local healthTextX = healthBarX + (healthBarWidth - fonts.small:getWidth(healthText)) / 2
    drawTextWithShadow(healthText, healthTextX, healthY + 2, fonts.small, colorsConst.WHITE)

    -- ALTO CENTRO - Punti
    local scoreText = "SCORE: " .. data.score
    drawTextWithShadow(scoreText, 0, padding, fonts.large, colorsConst.WHITE, "center")

    -- ALTO DESTRA - Coins
    local coinsText = "COINS: " .. data.coins
    local coinsTextWidth = fonts.medium:getWidth(coinsText)
    local coinsX = scaling.GAME_WIDTH - coinsTextWidth - padding
    drawTextWithShadow(coinsText, coinsX, padding + 5, fonts.medium, colorsConst.GOLD)

    -- BASSO CENTRO - Potenziamenti (placeholder slots)
    local powerupY = scaling.GAME_HEIGHT - padding - slotSize
    local slotSpacing = 10
    local totalWidth = numSlots * slotSize + (numSlots - 1) * slotSpacing
    local startX = (scaling.GAME_WIDTH - totalWidth) / 2

    for i = 1, numSlots do
        local slotX = startX + (i - 1) * (slotSize + slotSpacing)

        -- Slot background
        love.graphics.setColor(colorsConst.SLOT_BG)
        love.graphics.rectangle("fill", slotX, powerupY, slotSize, slotSize, 5, 5)

        -- Slot border
        love.graphics.setColor(colorsConst.SLOT_BORDER)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", slotX, powerupY, slotSize, slotSize, 5, 5)
        love.graphics.setLineWidth(1)
    end

    -- Reset color
    love.graphics.setColor(colorsConst.WHITE)
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

function hud.setLives(lives)
    data.health = lives
end

function hud.setScore(newScore)
    data.score = newScore
end

function hud.getData()
    return data
end

return hud

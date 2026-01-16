local background = require("src.background")
local menu = require("src.menu")
local shipEditor = require("src.ship_editor")
local gameplay = require("src.gameplay")
local button = require("src.button")

local gameState = "menu" -- "menu", "editor", "game"
local shipData = nil

-- Fixed game resolution
local GAME_WIDTH = 800
local GAME_HEIGHT = 600

-- Scaling variables for window resize
local scale = 1
local offsetX = 0
local offsetY = 0

-- CRT Shader
local crtShader = nil
local gameCanvas = nil
local crtEnabled = true

local crtSettings = {
    scanlineIntensity = 0.15,
    curvature = 6.0,
    vignetteIntensity = 0.3,
    brightness = 1.05
}

-- Calculate scaling and offset to maintain aspect ratio
local function calculateScaling(windowWidth, windowHeight)
    local scaleX = windowWidth / GAME_WIDTH
    local scaleY = windowHeight / GAME_HEIGHT
    scale = math.min(scaleX, scaleY) -- Maintain aspect ratio
    offsetX = (windowWidth - GAME_WIDTH * scale) / 2
    offsetY = (windowHeight - GAME_HEIGHT * scale) / 2
end

-- Transform mouse coordinates from window to game canvas
local function transformMouseCoords(x, y)
    local gameX = (x - offsetX) / scale
    local gameY = (y - offsetY) / scale
    -- Clamp to canvas bounds
    gameX = math.max(0, math.min(GAME_WIDTH, gameX))
    gameY = math.max(0, math.min(GAME_HEIGHT, gameY))
    return gameX, gameY
end

local function startGame(data)
    shipData = data
    gameState = "game"
    gameplay.load(data)
end

local function startEditor()
    gameState = "editor"
    shipEditor.load(startGame)
end

function love.load()
    love.window.setTitle("Space Invaders")

    -- Load CRT shader
    local shaderSuccess, shaderError = pcall(function()
        crtShader = love.graphics.newShader("shaders/crt.glsl")
    end)

    if not shaderSuccess then
        print("Warning: CRT shader failed to load. Running without shader effect.")
        print("Error: " .. tostring(shaderError))
        crtEnabled = false
    end

    -- Create fixed-size canvas for rendering
    gameCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

    -- Calculate initial scaling
    local w, h = love.graphics.getDimensions()
    calculateScaling(w, h)

    background.load()
    menu.load(startEditor)
end

function love.update(dt)
    background.update(dt)

    if gameState == "menu" then
        menu.update()
    elseif gameState == "editor" then
        shipEditor.update()
    elseif gameState == "game" then
        gameplay.update(dt)
    end
end

function love.draw()
    -- Render everything to fixed-size canvas
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)

    background.draw()

    if gameState == "menu" then
        menu.draw()
    elseif gameState == "editor" then
        shipEditor.draw()
    elseif gameState == "game" then
        gameplay.draw()
    end

    love.graphics.setCanvas()

    -- Clear screen with black (for letterboxing)
    love.graphics.clear(0, 0, 0, 1)

    -- Apply CRT shader if enabled
    if crtEnabled and crtShader then
        love.graphics.setShader(crtShader)

        crtShader:send("resolution", { GAME_WIDTH, GAME_HEIGHT })
        crtShader:send("time", love.timer.getTime())
        crtShader:send("scanlineIntensity", crtSettings.scanlineIntensity)
        crtShader:send("curvature", crtSettings.curvature)
        crtShader:send("vignetteIntensity", crtSettings.vignetteIntensity)
        crtShader:send("brightness", crtSettings.brightness)
    end

    -- Draw scaled canvas to screen with letterboxing
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, offsetX, offsetY, 0, scale, scale)

    if crtEnabled and crtShader then
        love.graphics.setShader()
    end
end

function love.mousepressed(x, y, button)
    local gameX, gameY = transformMouseCoords(x, y)

    if gameState == "menu" then
        menu.mousepressed(gameX, gameY, button)
    elseif gameState == "editor" then
        shipEditor.mousepressed(gameX, gameY, button)
    end
end

function love.mousemoved(x, y)
    local gameX, gameY = transformMouseCoords(x, y)

    if gameState == "editor" then
        shipEditor.mousemoved(gameX, gameY)
    end
end

function love.keypressed(key)
    if gameState == "game" and key == "escape" then
        gameState = "menu"
    end

    -- Toggle CRT shader with F1
    if key == "f1" and crtShader then
        crtEnabled = not crtEnabled
        print("CRT Effect: " .. (crtEnabled and "ON" or "OFF"))
    end
end

function love.resize(w, h)
    -- Recalculate scaling for new window size
    menu.calculateScaling(w, h)
    calculateScaling(w, h)
end

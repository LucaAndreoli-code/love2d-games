local background = require("src.background")
local menu = require("src.menu")
local shipEditor = require("src.ship_editor")
local gameplay = require("src.gameplay")
local scaling = require("src.scaling")

local gameState = "menu"
local shipData = nil

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
    gameCanvas = love.graphics.newCanvas(scaling.GAME_WIDTH, scaling.GAME_HEIGHT)

    -- Calculate initial scaling
    local w, h = love.graphics.getDimensions()
    scaling.update(w, h)

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

        crtShader:send("resolution", { scaling.GAME_WIDTH, scaling.GAME_HEIGHT })
        crtShader:send("time", love.timer.getTime())
        crtShader:send("scanlineIntensity", crtSettings.scanlineIntensity)
        crtShader:send("curvature", crtSettings.curvature)
        crtShader:send("vignetteIntensity", crtSettings.vignetteIntensity)
        crtShader:send("brightness", crtSettings.brightness)
    end

    -- Draw scaled canvas to screen with letterboxing
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, scaling.offsetX, scaling.offsetY, 0, scaling.scale, scaling.scale)

    if crtEnabled and crtShader then
        love.graphics.setShader()
    end
end

function love.mousepressed(x, y, button)
    local gameX, gameY = scaling.toGame(x, y)

    if gameState == "menu" then
        menu.mousepressed(gameX, gameY, button)
    elseif gameState == "editor" then
        shipEditor.mousepressed(gameX, gameY, button)
    end
end

function love.mousemoved(x, y)
    local gameX, gameY = scaling.toGame(x, y)

    if gameState == "editor" then
        shipEditor.mousemoved(gameX, gameY)
    end
end

function love.keypressed(key)
    -- if gameState == "game" and key == "q" then
    --     gameState = "menu"
    -- end

    -- Toggle CRT shader with F1
    if key == "c" and crtShader then
        crtEnabled = not crtEnabled
        print("CRT Effect: " .. (crtEnabled and "ON" or "OFF"))
    end
end

function love.resize(w, h)
    -- Recalculate scaling for new window size
    scaling.update(w, h)
end

function shipEditor.back()
    gameState = "menu"
end

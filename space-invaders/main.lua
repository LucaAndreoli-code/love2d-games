local background = require("src.background")
local menu = require("src.menu")
local shipEditor = require("src.ship_editor")
local gameplay = require("src.gameplay")

local gameState = "menu" -- "menu", "editor", "game"
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

    -- Create canvas for rendering
    local w, h = love.graphics.getDimensions()
    gameCanvas = love.graphics.newCanvas(w, h)

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
    love.graphics.setBackgroundColor(0, 0, 0)

    if crtEnabled and crtShader and gameCanvas then
        -- Render everything to canvas
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

        -- Apply CRT shader and draw canvas to screen
        love.graphics.setShader(crtShader)

        local w, h = love.graphics.getDimensions()
        crtShader:send("resolution", {w, h})
        crtShader:send("time", love.timer.getTime())
        crtShader:send("scanlineIntensity", crtSettings.scanlineIntensity)
        crtShader:send("curvature", crtSettings.curvature)
        crtShader:send("vignetteIntensity", crtSettings.vignetteIntensity)
        crtShader:send("brightness", crtSettings.brightness)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(gameCanvas, 0, 0)

        love.graphics.setShader()
    else
        -- Fallback: render without shader
        background.draw()

        if gameState == "menu" then
            menu.draw()
        elseif gameState == "editor" then
            shipEditor.draw()
        elseif gameState == "game" then
            gameplay.draw()
        end
    end
end

function love.mousepressed(x, y, button)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    elseif gameState == "editor" then
        shipEditor.mousepressed(x, y, button)
    end
end

function love.mousemoved(x, y)
    if gameState == "editor" then
        shipEditor.mousemoved(x, y)
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
    -- Recreate canvas with new dimensions
    if gameCanvas then
        gameCanvas:release()
    end
    gameCanvas = love.graphics.newCanvas(w, h)

    background.resize(w, h)

    if gameState == "menu" then
        menu.resize(w, h)
    elseif gameState == "editor" then
        shipEditor.resize(w, h)
    elseif gameState == "game" then
        gameplay.resize(w, h)
    end
end

local background = require("src.background")
local menu = require("src.menu")
local shipEditor = require("src.ship_editor")
local gameplay = require("src.gameplay")

local gameState = "menu" -- "menu", "editor", "game"
local shipData = nil

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
    love.window.setMode(800, 600)
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
    background.draw()

    if gameState == "menu" then
        menu.draw()
    elseif gameState == "editor" then
        shipEditor.draw()
    elseif gameState == "game" then
        gameplay.draw()
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
end

function love.resize(w, h)
    background.resize(w, h)

    if gameState == "menu" then
        menu.resize(w, h)
    elseif gameState == "editor" then
        shipEditor.resize(w, h)
    elseif gameState == "game" then
        gameplay.resize(w, h)
    end
end

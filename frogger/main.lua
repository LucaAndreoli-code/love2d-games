local Sprites = require("src.sprites")
local Constants = require("src.constants")
local Frogger = require("src.frogger")
local Lanes = require("src.lanes")
local GameCanvas = require("src.canvas")
local Screen = require("src.screen")
local Debug = require("src.debug")
local Points = require("src.points")

function love.load()
    --SCREEN AND CANVAS SETUP
    Screen:initializeScreen()
    GameCanvas:load()

    --GAME SETUP
    GameSprites = Sprites.load()
    Frogger:init(GameSprites)
    Lanes:init()

    love.window.setTitle("Frogger")
end

function love.update(dt)
    Frogger:handleHopping(dt)
end

function love.draw()
    GameCanvas:setCanvas()

    Lanes:draw()
    Lanes:drawObstacles()
    Frogger:draw()
    Points:draw()

    GameCanvas:setWindow()
end

function love.keypressed(key)
    Frogger:move(key)
    Debug:toggle(key)
end

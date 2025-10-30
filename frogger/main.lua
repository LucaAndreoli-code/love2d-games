local Sprites = require("src.sprites")
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

    love.window.setTitle("Frogger")
end

function love.update(dt)
    Frogger:handleHopping(dt)
end

function love.draw()
    GameCanvas:setCanvas()

    if Points.gameState == 'home' then
        Screen:drawHomeScreen()
    elseif Points.gameState == 'playing' then
        Lanes:draw()
        Lanes:drawObstacles()
        Frogger:draw()
        Points:draw()
        Lanes:verifyWinCondition()
    elseif Points.gameState == 'gameover' then
        Screen:drawGameOverScreen()
    end

    if Points.gameState == 'win' then
        love.graphics.print("YOU WIN!", 10, 70)
        love.graphics.print("Press arrow keys to restart", 10, 90)
    end

    GameCanvas:setWindow()
end

function love.keypressed(key)
    if Points.gameState ~= 'playing' then
        if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
            Points.gameState = 'playing'
            Points:reset()
        end
        return
    end
    Frogger:move(key)
    Debug:toggle(key)
end

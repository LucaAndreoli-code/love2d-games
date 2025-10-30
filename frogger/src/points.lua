local GameCanvas = require("src.canvas")
local Frogger = require("src.frogger")

local Points = {
    points = 0,
    lives = 3,
    gameState = 'home'
}

function Points:draw()
    GameCanvas:setPointCanvas()
    GameCanvas:setPointWindow()
    love.graphics.print("Points: " .. Points.points, 10, 10)
    love.graphics.print("Lives: " .. Points.lives, 100, 10)
end

function Points:add(value)
    Points.points = Points.points + value
end

function Points:loseLife()
    Points.lives = Points.lives - 1
    if Points.lives <= 0 then
        Points.gameState = 'gameover'
        Points:reset()
        Frogger:resetPosition()
    else

    end
end

function Points:reset()
    Points.points = 0
    Points.lives = 3
    Points.gameOver = false
    Lanes = require("src.lanes")
    Lanes:clearLilypads()
end

return Points

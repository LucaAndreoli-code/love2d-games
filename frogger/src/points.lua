local GameCanvas = require("src.canvas")
local Points = {
    points = 0,
    lives = 3,
    gameOver = false
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
        print("Game Over! No lives left.")
        Points:reset()
        -- Here you can add game over logic, like resetting the game or showing a game over screen
    else

    end
end

function Points:reset()
    Points.points = 0
    Points.lives = 3
    Points.gameOver = false
end

return Points

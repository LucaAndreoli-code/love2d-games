Points = require("src.points")

local Screen = {}

function Screen:initializeScreen()
    love.graphics.getDimensions()
end

function Screen:drawHomeScreen()
    love.graphics.print("FROGGER", 10, 30)
    love.graphics.print("Press arrow keys to move", 10, 50)
end

function Screen:drawGameOverScreen()
    love.graphics.print("GAME OVER", 10, 30)
    love.graphics.print("Press any arrow key to restart", 10, 50)
end

return Screen

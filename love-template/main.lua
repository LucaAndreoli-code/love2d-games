local Game = {}
_G.Game    = Game

function love.load()
    Game.debug  = require("src.debug")
    Game.logger = require("src.logger")

    Game.logger.info("Loading game...")
    love.window.setTitle("BASE")
    love.window.setMode(800, 600)
    Game.logger.debug("Game started")
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)

    if Game.debug.active then
        Game.debug.draw()
    end
    -- Game drawing goes here
end

function love.update(dt)
    -- Game logic goes here
end

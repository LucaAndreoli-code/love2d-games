function love.load()
    W, H = love.graphics.getDimensions()

    Paddle = {
        x = W / 2 - 100,
        y = H - 50,
        width = 200,
        height = 10,
        speed = 300
    }

    Ball = {
        x = W / 2,
        y = H / 2,
        radius = 10,
        speedX = 200,
        speedY = -200
    }

    GameState = {
        lives = 3,
        score = 0,
        state = 'start' -- start, playing, gameover
    }
end

function love.draw()
    -- paddle
    love.graphics.rectangle('fill', Paddle.x, Paddle.y, Paddle.width, Paddle.height)

    -- linea sotto paddle
    love.graphics.rectangle('line', -10, H - 10, W + 20, 30)

    -- pallina
    if (GameState.state == 'start') then -- STATO INIZIALE
        love.graphics.printf('Press Space to Start', 0, H / 2 - 50, W, 'center')
        love.graphics.circle('fill', (Paddle.x + Paddle.width / 2), Paddle.y - Ball.radius, Ball.radius)
    elseif (GameState.state == 'gameover') then -- PARTITA FINITA
        love.graphics.printf('Game Over! Press Space to Restart', 0, H / 2 - 50, W, 'center')
    else                                        -- GIOCANDO
        love.graphics.circle('fill', Ball.x, Ball.y, Ball.radius)
    end
end

function love.update(dt)
    MovePaddle(dt)
end

function MovePaddle(dt)
    -- notare quanto é smart l'uso di math.max e math.min per evitare che la paddle esca dallo schermo
    if love.keyboard.isDown('left') then
        Paddle.x = math.max(0, Paddle.x - Paddle.speed * dt)
    elseif love.keyboard.isDown('right') then
        Paddle.x = math.min(W - Paddle.width, Paddle.x + Paddle.speed * dt)
    end
end

-- TODO CHECK
function love.keypressed(key)
    if key == 'space' then
        if GameState.state == 'start' then
            GameState.state = 'playing'
        elseif GameState.state == 'gameover' then
            -- reset game
            GameState.lives = 3
            GameState.score = 0
            Ball.x = W / 2
            Ball.y = H / 2
            GameState.state = 'start'
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end

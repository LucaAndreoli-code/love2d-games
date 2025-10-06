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
end

function love.draw()
    -- paddle
    love.graphics.rectangle('fill', Paddle.x, Paddle.y, Paddle.width, Paddle.height)

    -- linea sotto paddle
    love.graphics.rectangle('line', -10, H - 10, W + 20, 30)

    -- pallina
    love.graphics.circle('fill', Ball.x, Ball.y, Ball.radius)
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

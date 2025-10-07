function love.load()
    W, H = love.graphics.getDimensions()

    Paddle = {
        x = W / 2 - 100,
        y = H - 50,
        width = W / 6,
        height = 10,
        speed = 300
    }

    Ball = {
        x = W / 2,
        y = H / 2,
        radius = 10,
        speedX = 200,
        speedY = 200,
    }

    GameState = {
        lives = 3,
        score = 0,
        state = 'start' -- start, playing, gameover
    }

    ROWS = 6
    COLS = 8
    PADDING = 5
    Blocks = {
        rows = ROWS,
        cols = COLS,
        width = (W - PADDING * (COLS + 1)) / COLS, -- calcolo la larghezza dei blocchi in base alla larghezza della finestra
        height = 30,
        grid = {}
    }

    InitializeBlocks()
end

function love.draw()
    -- paddle
    love.graphics.rectangle('fill', Paddle.x, Paddle.y, Paddle.width, Paddle.height)

    -- linea sotto paddle
    love.graphics.rectangle('line', -10, H - 10, W + 20, 30)

    -- pallina
    if (GameState.state == 'start') then -- STATO INIZIALE
        love.graphics.printf('Press Space to Start', 0, H / 2 - 50, W, 'center')
        Ball.x = (Paddle.x + Paddle.width / 2)
        Ball.y = Paddle.y - Ball.radius
        love.graphics.circle('fill', Ball.x, Ball.y, Ball.radius)
        DrawBlocks()
    elseif (GameState.state == 'gameover') then -- PARTITA FINITA
        love.graphics.printf('Final Score: ' .. GameState.score, 0, H / 2 - 80, W, 'center')
        love.graphics.printf('Game Over! Press Space to Restart', 0, H / 2 - 50, W, 'center')
    elseif (GameState.state == 'victory') then
        love.graphics.printf('Press Space to continue to the next level: ' .. GameState.score, 0, H / 2 - 50, W, 'center')
    else
        love.graphics.circle('fill', Ball.x, Ball.y, Ball.radius)
        DrawBlocks()
    end
end

function love.update(dt)
    MovePaddle(dt)
    if (GameState.state == 'playing') then
        MoveBall(dt)
    end
    CheckVictory()
end

function CheckVictory()
    for row = 0, Blocks.rows - 1 do
        for col = 0, Blocks.cols - 1 do
            local block = Blocks.grid[row][col]
            if block.status == 1 then
                return -- se c'è almeno un blocco attivo, esci dalla funzione
            end
        end
    end
    GameState.state = 'victory'
end

function MovePaddle(dt)
    -- notare quanto é smart l'uso di math.max e math.min per evitare che la paddle esca dallo schermo
    if love.keyboard.isDown('left') then
        Paddle.x = math.max(0, Paddle.x - Paddle.speed * dt)
    elseif love.keyboard.isDown('right') then
        Paddle.x = math.min(W - Paddle.width, Paddle.x + Paddle.speed * dt)
    end
end

function MoveBall(dt)
    Ball.prevX = Ball.x
    Ball.prevY = Ball.y

    Ball.x = Ball.x + Ball.speedX * dt
    Ball.y = Ball.y + Ball.speedY * dt

    -- collisione con i muri
    if Ball.x - Ball.radius < 0 then
        Ball.x = Ball.radius
        Ball.speedX = -Ball.speedX
    elseif Ball.x + Ball.radius > W then
        Ball.x = W - Ball.radius
        Ball.speedX = -Ball.speedX
    end

    if Ball.y - Ball.radius < 0 then
        Ball.y = Ball.radius
        Ball.speedY = -Ball.speedY
    end

    -- se la pallina tocca il fondo, perdi una vita
    if Ball.y - Ball.radius > H then
        GameState.lives = GameState.lives - 1
        if GameState.lives <= 0 then
            GameState.state = 'gameover'
        else
            -- resetta la pallina e torna allo stato iniziale
            Ball.x = W / 2
            Ball.y = H / 2
            GameState.state = 'start'
        end
    end

    CheckBallPaddleCollision()
    CheckBallBlockCollision()
end

function CheckBallPaddleCollision()
    -- COLLISIONE CON PADDLE
    if Ball.x + Ball.radius > Paddle.x and
        Ball.x - Ball.radius < Paddle.x + Paddle.width and
        Ball.y + Ball.radius > Paddle.y and
        Ball.y - Ball.radius < Paddle.y + Paddle.height then
        -- IMPORTANTE - CAPISCE DOVE STO COLPENDO SE LATERALMENTE O SOPRA/SOTTO
        local leftIntersect = (Ball.x + Ball.radius) - Paddle.x
        local rightIntersect = (Paddle.x + Paddle.width) - (Ball.x - Ball.radius)
        local topIntersect = (Ball.y + Ball.radius) - Paddle.y

        -- TROVA IL PIU' PICCOLO
        local minIntersect = math.min(leftIntersect, rightIntersect, topIntersect)

        if minIntersect == topIntersect then
            -- COLLISIONE SOPRA
            Ball.y = Paddle.y - Ball.radius
            Ball.speedY = -Ball.speedY
        elseif minIntersect == leftIntersect then
            -- COLLISIONE A SINISTRA
            Ball.x = Paddle.x - Ball.radius
            Ball.speedX = -Ball.speedX
        elseif minIntersect == rightIntersect then
            -- COLLISIONE A DESTRA
            Ball.x = Paddle.x + Paddle.width + Ball.radius
            Ball.speedX = -Ball.speedX
        end
    end
end

function CheckBallBlockCollision()
    for row = 0, Blocks.rows - 1 do
        for col = 0, Blocks.cols - 1 do
            local block = Blocks.grid[row][col]
            if block.status == 1 then
                -- COLLISIONE CON BLOCCO
                if Ball.x + Ball.radius > block.x and
                    Ball.x - Ball.radius < block.x + Blocks.width and
                    Ball.y + Ball.radius > block.y and
                    Ball.y - Ball.radius < block.y + Blocks.height then
                    -- IMPORTANTE -- CAPISCE DOVE STO COLPENDO SE LATERALMENTE O SOPRA/SOTTO
                    local leftIntersect = (Ball.x + Ball.radius) - block.x
                    local rightIntersect = (block.x + Blocks.width) - (Ball.x - Ball.radius)
                    local topIntersect = (Ball.y + Ball.radius) - block.y
                    local bottomIntersect = (block.y + Blocks.height) - (Ball.y - Ball.radius)

                    -- TROVA IL PIU' PICCOLO
                    -- Questo determina la direzione della collisione
                    local minIntersect = math.min(leftIntersect, rightIntersect, topIntersect, bottomIntersect)

                    if minIntersect == leftIntersect or minIntersect == rightIntersect then
                        -- COLLISIONE LATERALE
                        Ball.speedX = -Ball.speedX

                        -- RIPOSIZIONA LA PALLINA
                        if minIntersect == leftIntersect then
                            Ball.x = block.x - Ball.radius
                        else
                            Ball.x = block.x + Blocks.width + Ball.radius
                        end
                    else
                        -- COLLISIONE VERTICALE
                        Ball.speedY = -Ball.speedY

                        -- RIPOSIZIONA LA PALLINA
                        if minIntersect == topIntersect then
                            Ball.y = block.y - Ball.radius
                        else
                            Ball.y = block.y + Blocks.height + Ball.radius
                        end
                    end

                    block.status = 0
                    GameState.score = GameState.score + 1
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == 'space' then
        if GameState.state == 'start' then
            GameState.state = 'playing'
        elseif GameState.state == 'victory' then
            -- aumenta il numero di righe e colonne per il prossimo livello
            if (Blocks.rows < 8) then
                Blocks.rows = Blocks.rows + 1
                Blocks.cols = Blocks.cols + 1
            end

            Blocks.width = (W - PADDING * (Blocks.cols + 1)) / Blocks.cols
            InitializeBlocks()
            GameState.state = 'start'
        elseif GameState.state == 'gameover' then
            -- reset game
            GameState.lives = 3
            GameState.score = 0
            Ball.x = W / 2
            Ball.y = H / 2
            GameState.state = 'start'
            InitializeBlocks()
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end

-- BLOCKS MANAGEMENT
function InitializeBlocks()
    for row = 0, Blocks.rows - 1 do
        Blocks.grid[row] = {}
        for col = 0, Blocks.cols - 1 do
            -- padding tra i blocchi e bordo
            local x = PADDING + col * (Blocks.width + PADDING)
            local y = PADDING + row * (Blocks.height + PADDING)
            Blocks.grid[row][col] = {
                x = x,
                y = y,
                status = 1
            }
        end
    end
end

function DrawBlocks()
    local rowColors = {
        { 1,   0,   0 }, -- Red
        { 0,   1,   0 }, -- Green
        { 0,   0,   1 }, -- Blue
        { 1,   1,   0 }, -- Yellow
        { 1,   0,   1 }, -- Magenta
        { 0,   1,   1 }, -- Cyan
        { 1,   0.5, 0 }, -- Orange
        { 0.5, 0,   1 }, -- Purple
    }

    for row = 0, Blocks.rows - 1 do
        local colorIndex = row % #rowColors + 1
        love.graphics.setColor(rowColors[colorIndex])
        for col = 0, Blocks.cols - 1 do
            if Blocks.grid[row][col].status == 1 then
                local block = Blocks.grid[row][col]
                love.graphics.rectangle('fill', block.x, block.y, Blocks.width, Blocks.height)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
end

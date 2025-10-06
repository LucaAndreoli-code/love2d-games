function love.load()
    W, H = love.graphics.getDimensions()

    GameState = {
        gameSpeed = 0.1, -- lower is faster
        gameOver = false,
        gameStarted = false,
        score = 0
    }

    Snake = {
        size = 20,
        tail = {},
        reset = function()
            Snake.tail = {
                { -- Initial Tail Segment
                    x = W / 2,
                    y = H / 2,
                },
                {
                    x = W / 2 - 20,
                    y = H / 2,
                },
                {
                    x = W / 2 - 40,
                    y = H / 2,
                }
            }
        end
    }

    Bounds = {
        x = Snake.size,
        y = Snake.size,
        width = W - Snake.size * 2,
        height = H - Snake.size * 2
    }

    Food = {
        x = math.random(Bounds.x / Snake.size, Bounds.width / Snake.size) * Snake.size,
        y = math.random(Bounds.y / Snake.size, Bounds.height / Snake.size) * Snake.size,
        size = Snake.size
    }

    Key = "right"
    KeyGoing = "right"
end

function love.draw()
    if (GameState.gameOver) then
        love.graphics.printf("Game Over! Score: " .. GameState.score .. "\nPress R to Restart", 0, H / 2 - 50, W,
            "center")
        if love.keyboard.isDown("r") then
            -- Reset Game State
            GameState.gameOver = false
            GameState.score = 0
            Snake.reset()
            Key = "right"
            KeyGoing = "right"
            Food = nil
        end
        return
    end

    if (not GameState.gameStarted) then
        love.graphics.printf("Press Any Arrow Key to Start", 0, H / 2 - 50, W, "center")
        if love.keyboard.isDown("right") or love.keyboard.isDown("left") or love.keyboard.isDown("up") or
            love.keyboard.isDown("down") then
            GameState.gameStarted = true
            Snake.reset()
        end
        return
    end

    local time = love.timer.getTime()
    local r = (math.sin(time * 0.9) + 1) / 2
    local g = (math.sin(time * 0.9 + 2) + 1) / 2
    local b = (math.sin(time * 0.9 + 4) + 1) / 2
    love.graphics.setBackgroundColor(r, g, b)

    -- Draw filled black background for bounds
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", Bounds.x, Bounds.y, Bounds.width, Bounds.height)

    -- Reset color and draw outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", Bounds.x, Bounds.y, Bounds.width, Bounds.height)

    CheckSnakePosition()
    GenerateFood()
    DrawSnake()
end

function love.update()
    if (GameState.gameOver or not GameState.gameStarted) then
        return
    end

    love.timer.sleep(GameState.gameSpeed)
    MoveSnake()
    VerifySelfCollision()
end

function DrawSnake()
    for _, value in ipairs(Snake.tail) do
        love.graphics.rectangle("fill", value.x, value.y, Snake.size, Snake.size)
    end
end

function GenerateFood()
    if not Food then
        Food = {
            x = math.random(Bounds.x / Snake.size, Bounds.width / Snake.size) * Snake.size,
            y = math.random(Bounds.y / Snake.size, Bounds.height / Snake.size) * Snake.size,
            size = Snake.size
        }
    end
    love.graphics.setColor(1, 0, 0) -- Red Color
    love.graphics.rectangle("fill", Food.x, Food.y, Food.size, Food.size)
    love.graphics.setColor(1, 1, 1) -- Reset to White Color

    if Snake.tail[1].x == Food.x and Snake.tail[1].y == Food.y then
        table.insert(Snake.tail, { x = Food.x, y = Food.y }) -- Add new segment to the snake
        Food = nil
        GameState.score = #Snake.tail
    end
end

function CheckSnakePosition()
    for _, value in ipairs(Snake.tail) do
        if value.x >= Bounds.width + 1 then
            value.x = Bounds.x
        elseif value.x <= Bounds.y - 1 then
            value.x = Bounds.width
        elseif value.y >= Bounds.height + 1 then
            value.y = Bounds.y
        elseif value.y <= Bounds.y - 1 then
            value.y = Bounds.height
        end
    end
end

function love.keypressed(key)
    if Key == KeyGoing then
        if key == "right" then
            if (Key == "left") then
                return
            end
        elseif key == "left" then
            if (Key == "right") then
                return
            end
        elseif key == "down" then
            if (Key == "up") then
                return
            end
        elseif key == "up" then
            if (Key == "down") then
                return
            end
        end
        Key = key
    end
end

function MoveSnake()
    for i = #Snake.tail, 2, -1 do
        Snake.tail[i].x = Snake.tail[i - 1].x
        Snake.tail[i].y = Snake.tail[i - 1].y
    end
    if Key == "right" then
        Snake.tail[1].x = Snake.tail[1].x + Snake.size
    elseif Key == "left" then
        Snake.tail[1].x = Snake.tail[1].x - Snake.size
    elseif Key == "down" then
        Snake.tail[1].y = Snake.tail[1].y + Snake.size
    elseif Key == "up" then
        Snake.tail[1].y = Snake.tail[1].y - Snake.size
    end

    KeyGoing = Key
end

function VerifySelfCollision()
    for i, _ in ipairs(Snake.tail) do
        for j, _ in ipairs(Snake.tail) do
            if i ~= j and Snake.tail[j].x == Snake.tail[i].x and Snake.tail[j].y == Snake.tail[i].y then
                GameState.gameOver = true
            end
        end
    end
end

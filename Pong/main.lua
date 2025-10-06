function love.load()
    W, H = love.graphics.getDimensions()
    local distanceFromEdge = 50
    local paddleWidht, paddleHeight = 5, 150
    local hWithOffset = (H - paddleHeight) / 2
    Player1 = {
        x = distanceFromEdge,
        y = hWithOffset,
        width = paddleWidht,
        height = paddleHeight
    }
    
    Player2 = {
        x = W - distanceFromEdge - 20,
        y = hWithOffset,
        width = paddleWidht,
        height = paddleHeight
    }

    CenterLine = {
        x = W / 2 - 2,
        width = 4,
        dashLength = 15,
        gapLength = 10
    }

    Ball = {
        x = W / 2,
        y = H / 2,
        radius = 10,
        speedX = 5,
        speedY = 5
    }

    goal = {
        width = 20,
        height = H
    }

    WinningScore = 10
    PaddleSpeed = 4

    GameState = {
        winner = "",
        isOver = false,
        score1 = 0,
        score2 = 0
    }
end

function love.draw()
    if GameState.isOver then
        love.graphics.print("Player " .. GameState.winner .. " wins!", W / 2 - 50, H / 2)
        love.graphics.print("Press R to restart", W / 2 - 50, H / 2 + 20)
        CheckRestartGame()
        return
    else
        DrawCenterLine()

        -- Paddles and Ball
        love.graphics.rectangle("fill", Player1.x, Player1.y, Player1.width, Player1.height)
        love.graphics.rectangle("fill", Player2.x, Player2.y, Player2.width, Player2.height)
        love.graphics.circle("fill", Ball.x, Ball.y, Ball.radius)

        -- Porte
        love.graphics.rectangle("line", 0, 0, goal.width, goal.height)
        love.graphics.rectangle("line", W - goal.width, 0, goal.width, goal.height)

        -- Scores
        love.graphics.print("Player 1", W / 4, 20)
        love.graphics.print(GameState.score1, W / 4, 20 + 20)
        love.graphics.print("Player 2", 3 * W / 4, 20)
        love.graphics.print(GameState.score2, 3 * W / 4, 20 + 20)

        MovePlayer()
        MoveEnemy()
        MoveBall()
    end
end

function CheckRestartGame()
    if love.keyboard.isDown("r") then
        GameState.isOver = false
        GameState.winner = ""
        GameState.score1 = 0
        GameState.score2 = 0
        Ball.x = W / 2
        Ball.y = H / 2
        Player1.y = (H - Player1.height) / 2
        Player2.y = (H - Player2.height) / 2
    end
end

function MovePlayer()
    if love.keyboard.isDown("up") then
        if Player1.y <= 0 then
            return
        end
        Player1.y = Player1.y - PaddleSpeed
    elseif love.keyboard.isDown("down") then
        if Player1.y + Player1.height >= H then
            return
        end
        Player1.y = Player1.y + PaddleSpeed
    end
end

function MoveEnemy()
    if Player2.y <= 0 then
        Player2.y = 1
        return
    end
    if Player2.y + Player2.height >= H then
        Player2.y = H - Player2.height - 1
        return
    end
    if Ball.y < Player2.y + Player2.height / 2 then
        Player2.y = Player2.y - PaddleSpeed
    elseif Ball.y > Player2.y + Player2.height / 2 then
        Player2.y = Player2.y + PaddleSpeed
    end
end

function MoveBall()
    if (Ball.x - Ball.radius <= Player1.x + Player1.width and Ball.y + Ball.radius >= Player1.y and Ball.y - Ball.radius <=
        Player1.y + Player1.height) then
        Ball.speedX = -Ball.speedX
    end
    if (Ball.x + Ball.radius >= Player2.x and Ball.y + Ball.radius >= Player2.y and Ball.y - Ball.radius <= Player2.y +
        Player2.height) then
        Ball.speedX = -Ball.speedX
    end
    if (Ball.y - Ball.radius <= 0 or Ball.y + Ball.radius >= H) then
        Ball.speedY = -Ball.speedY
    end
    if (Ball.x - Ball.radius <= 0 or Ball.x + Ball.radius >= W) then
        Ball.speedX = -Ball.speedX
    end
    Ball.x = Ball.x + Ball.speedX
    Ball.y = Ball.y + Ball.speedY

    if Ball.x - Ball.radius < goal.width then
        GameState.score2 = GameState.score2 + 1
        if GameState.score2 >= WinningScore then
            GameState.isOver = true
            GameState.winner = "2"
        end
    elseif Ball.x + Ball.radius > W - goal.width then
        GameState.score1 = GameState.score1 + 1
        if GameState.score1 >= WinningScore then
            GameState.isOver = true
            GameState.winner = "1"
        end
    end

    if Ball.x - Ball.radius < goal.width or Ball.x + Ball.radius > W - goal.width then
        Ball.x = W / 2
        Ball.y = H / 2
    end

end

function DrawCenterLine()
    local y = 0
    while y < H do
        love.graphics.rectangle("fill", CenterLine.x, y, CenterLine.width, CenterLine.dashLength)
        y = y + CenterLine.dashLength + CenterLine.gapLength
    end
end


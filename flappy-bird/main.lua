function love.load()
    W, H = love.graphics.getDimensions()
    love.window.setTitle("FlappyBird")

    Gravity = 9.81 * 100
    JumpPower = -450

    GameState = {
        playing = false,
        lost = false,
        score = 0,
    }

    Player = {
        x = W / 2 - 25,
        y = H / 2 - 25,
        width = 30,
        height = 20,
        velocityY = 0,

        ---@param other {x: number, y: number, width: number, height: number}
        CollidesWith = function(self, other)
            return self.x < other.x + other.width and
                self.x + self.width > other.x and
                self.y < other.y + other.height and
                self.y + self.height > other.y
        end
    }

    Pipes = {
        {
            x = W,
            gap_y = love.math.random(200, H - 150),
            gap_size = love.math.random(150, 200),
            speed = BaseVelocity,
        },
    }

    LastPipeIndex = 1

    --PLAYER IMAGE
    Bird = love.graphics.newImage("assets/bird/yellowbird-midflap.png")

    --BACKGROUND IMAGE
    Background = love.graphics.newImage("assets/background/background-day.png")
    Base = love.graphics.newImage("assets/background/base.png")
    Backgrounds = {
        { x = -Background:getWidth() },
        { x = 0 },
        { x = Background:getWidth() },
        { x = Background:getWidth() * 2 },
        { x = Background:getWidth() * 3 },
    }
    Bases = {
        { x = -Base:getWidth() },
        { x = 0 },
        { x = Base:getWidth() },
        { x = Base:getWidth() * 2 },
        { x = Base:getWidth() * 3 },
    }

    --PIPE IMAGE
    GreenPipe = love.graphics.newImage("assets/pipe/pipe-green.png")

    --FONT
    Font = love.graphics.newFont("assets/font/font.ttf", 24)
    love.graphics.setFont(Font)

    BackgroundVelocity = 90
    BaseVelocity = 170
end

function love.draw()
    -- Draw scrolling background
    for _, bg in ipairs(Backgrounds) do
        love.graphics.draw(Background, bg.x, 0)
        bg.x = bg.x - BackgroundVelocity * love.timer.getDelta()
        if bg.x <= -Background:getWidth() then
            bg.x = bg.x + Background:getWidth() * #Backgrounds
        end
    end

    -- Draw scrolling base
    for _, base in ipairs(Bases) do
        love.graphics.draw(Base, base.x, H - Base:getHeight() + 80)
        base.x = base.x - BaseVelocity * love.timer.getDelta()
        if base.x <= -Base:getWidth() then
            base.x = base.x + Base:getWidth() * #Bases
        end
    end

    if not GameState.playing and not GameState.lost then
        love.graphics.print("Flappy Bird Clone", W / 2 - 130, 50)
        love.graphics.print("Press Space to Start", W / 2 - 130, 70)
    end

    if GameState.playing then
        love.graphics.print(GameState.score, 10, 10)
        love.graphics.draw(Bird, Player.x, Player.y)
        for i, _ in ipairs(Pipes) do
            DrawPipe(i)
        end
    end

    if not GameState.playing and GameState.lost then
        love.graphics.print("Game Over \n Press Space to Restart", W / 2 - 150, 50)
    end
end

function love.keypressed(key)
    if key == "space" then
        Player.velocityY = JumpPower
    end
end

function love.update(dt)
    if GameState.playing then
        Player.velocityY = Player.velocityY + Gravity * dt
        Player.y = Player.y + Player.velocityY * dt

        for i, _ in ipairs(Pipes) do
            MovePipe(i, dt)
        end

        if Pipes[LastPipeIndex].x <= W / 1.5 then
            print("New Pipe")
            table.insert(Pipes, {
                x = W,
                gap_y = love.math.random(200, H - 150),
                gap_size = love.math.random(150, 200),
                speed = BaseVelocity,
            })
            LastPipeIndex = LastPipeIndex + 1
        end
        for i = #Pipes, 1, -1 do
            if Pipes[i].x + 50 < 0 then
                print("Remove Pipe")
                table.remove(Pipes, i)
                LastPipeIndex = LastPipeIndex - 1
            end
        end

        for i, pipe in ipairs(Pipes) do
            local pipe_top = { x = pipe.x, y = 0, width = 50, height = pipe.gap_y - pipe.gap_size / 2 }
            local pipe_bottom = {
                x = pipe.x,
                y = pipe.gap_y + pipe.gap_size / 2,
                width = 50,
                height = H -
                    (pipe.gap_y + pipe.gap_size / 2)
            }

            if Player:CollidesWith(pipe_top) or Player:CollidesWith(pipe_bottom) then
                GameState.playing = false
                GameState.lost = true
            end

            -- Check if player has passed between pipes
            if pipe.x + 50 < Player.x and not pipe.scored then
                GameState.score = GameState.score + 1
                pipe.scored = true
            end
        end

        if Player.y < 0 or Player.y + Player.height > H - 30 then
            GameState.playing = false
            GameState.lost = true
        end
    end
    if not GameState.playing and love.keyboard.isDown("space") then
        Reset()
    end
end

function DrawPipe(index)
    love.graphics.draw(GreenPipe, Pipes[index].x, Pipes[index].gap_y - Pipes[index].gap_size / 2, 0, 1, -1)
    love.graphics.draw(GreenPipe, Pipes[index].x, Pipes[index].gap_y + Pipes[index].gap_size / 2)
end

function MovePipe(index, dt)
    Pipes[index].x = Pipes[index].x - Pipes[index].speed * dt
end

function Reset()
    Player.y = H / 2 - 25
    Player.velocityY = 0
    Pipes = {
        {
            x = W,
            gap_y = love.math.random(200, H - 150),
            gap_size = love.math.random(150, 200),
            speed = BaseVelocity,
        },
    }
    LastPipeIndex = 1
    GameState.score = 0
    GameState.playing = true
end

local Constants = require("src.constants")
local Debug = require("src.debug")

local Frogger = {
    -- Proprietà di default
    x = 0,
    y = 0,
    rotation = 0,
    gridY = 12,
    width = 16,
    height = 16,
    isHopping = false,
    hopProgress = 0,
    startX = 0,
    startY = 0,
    targetX = 0,
    targetY = 0,
    sprites = nil
}

local TileWidth = Constants.GAME_WIDTH / Constants.GRID_WIDTH
local LaneHeight = Constants.GAME_HEIGHT / Constants.GRID_HEIGHT

function Frogger:init(gameSprites)
    self.sprites = gameSprites

    -- Ottieni dimensioni dallo sprite
    local _, _, frogWidth, frogHeight = gameSprites.quads.frog:getViewport()
    self.width = frogWidth
    self.height = frogHeight

    -- Posizione iniziale
    self.x = TileWidth * math.floor(Constants.GRID_WIDTH / 2)
    self.y = (Constants.GRID_HEIGHT - 1) * LaneHeight
    self.gridY = 12
    self.rotation = 0

    -- Reset stato hop
    self.isHopping = false
    self.hopProgress = 0
end

function Frogger:isOnPlatform(obstacle, laneY)
    return self.x < obstacle.x + obstacle.width and
        self.x + self.width > obstacle.x and
        self.y < laneY + LaneHeight and
        self.y + self.height > laneY
end

function Frogger:resetPosition()
    self.x = TileWidth * math.floor(Constants.GRID_WIDTH / 2)
    self.y = (Constants.GRID_HEIGHT - 1) * LaneHeight
    self.gridY = 12
    self.isHopping = false
    self.hopProgress = 0
end

function Frogger:reachedEnd()
    return Frogger.gridY == 1
end

function Frogger:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local quadToDraw = GameSprites.quads.frog
    if (self.isHopping) then
        quadToDraw = GameSprites.quads.frogJump
    else
        quadToDraw = GameSprites.quads.frog
    end

    love.graphics.draw(
        GameSprites.sheet, -- lo spritesheet
        quadToDraw,        -- il quad della rana
        self.x + 8,        -- posizione x
        self.y + 8,        -- posizione y
        self.rotation,     -- rotazione (0 = nessuna)
        1, 1,              -- scala x, y (1 = dimensione originale)
        8, 8               -- origine x, y (per la rotazione)
    )
    if Debug.enabled then
        love.graphics.rectangle('line', Frogger.x, Frogger.y, Frogger.width, Frogger.height)
    end
end

function Frogger:handleHopping(dt)
    if Frogger.isHopping then
        -- Aumenta il progresso del salto
        Frogger.hopProgress = Frogger.hopProgress + (dt / Constants.HOP_DURATION)

        if Frogger.hopProgress >= 1.0 then
            -- Salto completato
            Frogger.hopProgress = 1.0
            Frogger.x = Frogger.targetX
            Frogger.y = Frogger.targetY
            Frogger.isHopping = false
        else
            -- Interpola la posizione
            Frogger.x = Frogger.startX + (Frogger.targetX - Frogger.startX) * Frogger.hopProgress
            Frogger.y = Frogger.startY + (Frogger.targetY - Frogger.startY) * Frogger.hopProgress
        end
    end
end

function Frogger:move(key)
    if self.isHopping then
        return
    end

    -- Salva posizione di partenza
    self.startX = self.x
    self.startY = self.y

    -- Calcola target in base al tasto
    if key == 'up' then
        if self.gridY > 1 then
            self.targetX = self.x
            self.targetY = self.y - LaneHeight
            self.gridY = self.gridY - 1
            self.isHopping = true
            self.hopProgress = 0
            self.rotation = 0
        end
    elseif key == 'down' then
        if self.gridY < Constants.GRID_HEIGHT then
            self.targetX = self.x
            self.targetY = self.y + LaneHeight
            self.gridY = self.gridY + 1
            self.isHopping = true
            self.hopProgress = 0
            self.rotation = math.pi
        end
    elseif key == 'left' then
        if self.x - TileWidth >= 0 then
            self.targetX = self.x - TileWidth
            self.targetY = self.y
            self.isHopping = true
            self.hopProgress = 0
            self.rotation = -math.pi / 2
        end
    elseif key == 'right' then
        if self.x + TileWidth < Constants.GAME_WIDTH then
            self.targetX = self.x + TileWidth
            self.targetY = self.y
            self.isHopping = true
            self.hopProgress = 0
            self.rotation = math.pi / 2
        end
    end
end

return Frogger

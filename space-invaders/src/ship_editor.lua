local shipEditor = {}
local Button = require("src.button")

local font
local smallFont
local screenWidth, screenHeight

local GRID_SIZE = 16
local MARGIN = 20

local state = "draw" -- "draw", "firing", "confirm"
local grid = {}
local firingPoint = nil
local cellSize = 1
local gridOffsetX = 0
local gridOffsetY = 0

local colors = {
    { name = "Red",   r = 1, g = 0,   b = 0 },
    { name = "Blue",  r = 0, g = 0.2, b = 0.6 },
    { name = "Black", r = 0, g = 0,   b = 0 },
    { name = "Gray", r = 0.88, g = 0.88, b = 0.88 }
}
local selectedColor = 1

local buttonGroup = nil
local colorButtons = {}
local presetButtons = {}

local onStartGame = nil

local setupDrawButtons
local setupFiringButtons
local setupConfirmButtons

-- Preset ship designs (16x16 grids)
-- Colors: 1=Red, 2=Blue, 3=Black, 4=White, nil=empty
local presets = {
    {
        grid = {
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, 4,   4,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, 4,   2,   4,   4,   1,   4,   nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, 4,   4,   4,   2,   1,   4,   4,   4,   nil, nil, nil, nil },
            { nil, nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   nil, nil, nil },
            { nil, nil, 4,   4,   4,   4,   4,   1,   2,   4,   4,   4,   4,   4,   nil, nil },
            { nil, nil, 4,   4,   nil, 4,   2,   4,   4,   2,   4,   nil, 4,   4,   nil, nil },
            { nil, nil, 4,   4,   nil, nil, 4,   4,   4,   4,   nil, nil, 4,   4,   nil, nil },
            { nil, nil, 1,   1,   nil, nil, 4,   4,   4,   4,   nil, nil, 1,   1,   nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, 1,   1,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }
        }
    },
    {
        grid = {
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, 4,   4,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, 4,   4,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, 4,   4,   4,   4,   4,   4,   nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, 4,   4,   4,   4,   4,   4,   nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   nil, nil, nil, nil },
            { nil, nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   nil, nil, nil },
            { nil, nil, 4,   4,   nil, 4,   4,   4,   4,   4,   4,   nil, 4,   4,   nil, nil },
            { nil, 4,   4,   nil, nil, 4,   4,   4,   4,   4,   4,   nil, nil, 4,   4,   nil },
            { nil, 4,   nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, 4,   nil },
            { nil, 1,   nil, nil, nil, nil, nil, 1,   1,   nil, nil, nil, nil, nil, 1,   nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
        }
    },
    {
        grid = {
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, 4,   4,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, 4,   4,   4,   4,   4,   4,   nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   nil, nil, nil, nil },
            { nil, nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   nil, nil, nil },
            { nil, nil, 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   nil, nil },
            { nil, 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   nil },
            { 4,   4,   4,   nil, 4,   4,   4,   4,   4,   4,   4,   4,   nil, 4,   4,   4 },
            { 4,   4,   nil, nil, nil, 4,   4,   4,   4,   4,   4,   nil, nil, nil, 4,   4 },
            { 4,   nil, nil, nil, nil, nil, 4,   4,   4,   4,   nil, nil, nil, nil, nil, 4 },
            { nil, nil, nil, nil, nil, nil, nil, 4,   4,   nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
            { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },

        }
    },
}

local function initGrid()
    grid = {}
    for y = 1, GRID_SIZE do
        grid[y] = {}
        for x = 1, GRID_SIZE do
            grid[y][x] = nil
        end
    end
end

local function loadPreset(presetIndex)
    local preset = presets[presetIndex]
    if not preset then return end

    initGrid()
    for y = 1, GRID_SIZE do
        for x = 1, GRID_SIZE do
            if preset.grid[y] and preset.grid[y][x] then
                grid[y][x] = preset.grid[y][x]
            end
        end
    end
end

local function calculateGridLayout()
    local availableWidth = screenWidth - MARGIN * 2 - 100
    local availableHeight = screenHeight - 200

    cellSize = math.floor(math.min(availableWidth / GRID_SIZE, availableHeight / GRID_SIZE))
    cellSize = math.max(cellSize, 4)

    local gridPixelSize = cellSize * GRID_SIZE
    gridOffsetX = (screenWidth - gridPixelSize) / 2
    gridOffsetY = 100
end

local function setupPresetButtons()
    presetButtons = {}

    local previewSize = 48
    local previewScale = previewSize / GRID_SIZE
    local startX = gridOffsetX + cellSize * GRID_SIZE + 30
    local startY = gridOffsetY

    for i, preset in ipairs(presets) do
        table.insert(presetButtons, {
            x = startX,
            y = startY + (i - 1) * (previewSize + 10),
            width = previewSize,
            height = previewSize,
            presetIndex = i,
            preset = preset,
            scale = previewScale
        })
    end
end

setupDrawButtons = function()
    buttonGroup = Button.newGroup()
    colorButtons = {}

    local buttonY = screenHeight - 60
    local clearWidth = smallFont:getWidth("Clear")
    local gap = 40

    buttonGroup:add(Button.new({
        text = "Clear",
        x = screenWidth / 2 - clearWidth - gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            initGrid()
        end
    }))

    buttonGroup:add(Button.new({
        text = "Next",
        x = screenWidth / 2 + gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            state = "firing"
            setupFiringButtons()
        end
    }))

    local btnSize = 40
    local paletteX = gridOffsetX - btnSize - 30
    local paletteStartY = gridOffsetY

    for i, color in ipairs(colors) do
        local btnY = paletteStartY + (i - 1) * (btnSize + 10)
        table.insert(colorButtons, {
            x = paletteX,
            y = btnY,
            width = btnSize,
            height = btnSize,
            colorIndex = i,
            color = color
        })
    end

    setupPresetButtons()
end

setupFiringButtons = function()
    buttonGroup = Button.newGroup()
    colorButtons = {}
    presetButtons = {}

    local buttonY = screenHeight - 60
    local backWidth = smallFont:getWidth("Back")
    local gap = 40

    buttonGroup:add(Button.new({
        text = "Back",
        x = screenWidth / 2 - backWidth - gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            state = "draw"
            firingPoint = nil
            setupDrawButtons()
        end
    }))

    buttonGroup:add(Button.new({
        text = "Next",
        x = screenWidth / 2 + gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            if firingPoint then
                state = "confirm"
                setupConfirmButtons()
            end
        end
    }))
end

setupConfirmButtons = function()
    buttonGroup = Button.newGroup()
    colorButtons = {}
    presetButtons = {}

    local buttonY = screenHeight - 60
    local backWidth = smallFont:getWidth("Back")
    local gap = 40

    buttonGroup:add(Button.new({
        text = "Back",
        x = screenWidth / 2 - backWidth - gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            state = "firing"
            setupFiringButtons()
        end
    }))

    buttonGroup:add(Button.new({
        text = "Start Game",
        x = screenWidth / 2 + gap,
        y = buttonY,
        font = smallFont,
        onClick = function()
            if onStartGame then
                onStartGame({
                    grid = grid,
                    firingPoint = firingPoint
                })
            end
        end
    }))
end

function shipEditor.load(startGameCallback)
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    font = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 36)
    smallFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 24)

    onStartGame = startGameCallback

    state = "draw"
    firingPoint = nil
    initGrid()
    calculateGridLayout()
    setupDrawButtons()
end

function shipEditor.update()
    local mx, my = love.mouse.getPosition()
    buttonGroup:update(mx, my)
end

local function getGridCell(mx, my)
    local relX = mx - gridOffsetX
    local relY = my - gridOffsetY

    if relX >= 0 and relY >= 0 then
        local cellX = math.floor(relX / cellSize) + 1
        local cellY = math.floor(relY / cellSize) + 1

        if cellX >= 1 and cellX <= GRID_SIZE and cellY >= 1 and cellY <= GRID_SIZE then
            return cellX, cellY
        end
    end

    return nil, nil
end

function shipEditor.mousepressed(x, y, mouseButton)
    if mouseButton ~= 1 then return end

    if buttonGroup:checkClick(x, y, mouseButton) then
        return
    end

    if state == "draw" then
        for _, presetBtn in ipairs(presetButtons) do
            if x >= presetBtn.x and x <= presetBtn.x + presetBtn.width
                and y >= presetBtn.y and y <= presetBtn.y + presetBtn.height then
                loadPreset(presetBtn.presetIndex)
                return
            end
        end

        for _, colorBtn in ipairs(colorButtons) do
            if x >= colorBtn.x and x <= colorBtn.x + colorBtn.width
                and y >= colorBtn.y and y <= colorBtn.y + colorBtn.height then
                selectedColor = colorBtn.colorIndex
                return
            end
        end

        local cellX, cellY = getGridCell(x, y)
        if cellX and cellY then
            grid[cellY][cellX] = selectedColor
        end
    elseif state == "firing" then
        local cellX, cellY = getGridCell(x, y)
        if cellX and cellY and grid[cellY][cellX] then
            firingPoint = { x = cellX, y = cellY }
        end
    end
end

function shipEditor.mousemoved(x, y)
    if state == "draw" and love.mouse.isDown(1) then
        local cellX, cellY = getGridCell(x, y)
        if cellX and cellY then
            grid[cellY][cellX] = selectedColor
        end
    end
end

local function drawGrid()
    for y = 1, GRID_SIZE do
        for x = 1, GRID_SIZE do
            local px = gridOffsetX + (x - 1) * cellSize
            local py = gridOffsetY + (y - 1) * cellSize

            if grid[y][x] then
                local color = colors[grid[y][x]]
                love.graphics.setColor(color.r, color.g, color.b)
                love.graphics.rectangle("fill", px, py, cellSize, cellSize)
            else
                love.graphics.setColor(0.1, 0.1, 0.1)
                love.graphics.rectangle("fill", px, py, cellSize, cellSize)
            end

            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("line", px, py, cellSize, cellSize)
        end
    end
end

local function drawFiringPointMarker()
    if firingPoint then
        local px = gridOffsetX + (firingPoint.x - 1) * cellSize
        local py = gridOffsetY + (firingPoint.y - 1) * cellSize

        love.graphics.setColor(0, 1, 0)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", px - 2, py - 2, cellSize + 4, cellSize + 4)
        love.graphics.setLineWidth(1)

        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.circle("fill", px + cellSize / 2, py + cellSize / 2, cellSize / 4)
    end
end

local function drawColorPalette()
    for _, colorBtn in ipairs(colorButtons) do
        love.graphics.setColor(colorBtn.color.r, colorBtn.color.g, colorBtn.color.b)
        love.graphics.rectangle("fill", colorBtn.x, colorBtn.y, colorBtn.width, colorBtn.height)

        if colorBtn.colorIndex == selectedColor then
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", colorBtn.x, colorBtn.y, colorBtn.width, colorBtn.height)
        love.graphics.setLineWidth(1)
    end
end

local function drawPresetButtons()
    for _, presetBtn in ipairs(presetButtons) do
        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.rectangle("fill", presetBtn.x, presetBtn.y, presetBtn.width, presetBtn.height)

        local preset = presetBtn.preset
        for py = 1, GRID_SIZE do
            for px = 1, GRID_SIZE do
                if preset.grid[py] and preset.grid[py][px] then
                    local colorIndex = preset.grid[py][px]
                    local color = colors[colorIndex]
                    love.graphics.setColor(color.r, color.g, color.b)
                    love.graphics.rectangle("fill",
                        presetBtn.x + (px - 1) * presetBtn.scale,
                        presetBtn.y + (py - 1) * presetBtn.scale,
                        presetBtn.scale,
                        presetBtn.scale
                    )
                end
            end
        end

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", presetBtn.x, presetBtn.y, presetBtn.width, presetBtn.height)
    end
end

local function drawTitle(text)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    local textWidth = font:getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, 30)
end

local function drawPreview()
    local previewScale = 4
    local previewSize = GRID_SIZE * previewScale
    local previewX = (screenWidth - previewSize) / 2
    local previewY = gridOffsetY

    for y = 1, GRID_SIZE do
        for x = 1, GRID_SIZE do
            if grid[y][x] then
                local color = colors[grid[y][x]]
                love.graphics.setColor(color.r, color.g, color.b)
                local px = previewX + (x - 1) * previewScale
                local py = previewY + (y - 1) * previewScale
                love.graphics.rectangle("fill", px, py, previewScale, previewScale)
            end
        end
    end

    if firingPoint then
        local fpx = previewX + (firingPoint.x - 1) * previewScale
        local fpy = previewY + (firingPoint.y - 1) * previewScale

        love.graphics.setColor(0, 1, 0)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", fpx - 1, fpy - 1, previewScale + 2, previewScale + 2)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", previewX, previewY, previewSize, previewSize)
end

function shipEditor.draw()
    if state == "draw" then
        drawTitle("Step 1: Draw Your Ship")
        drawGrid()
        drawColorPalette()
        drawPresetButtons()
    elseif state == "firing" then
        drawTitle("Step 2: Select Firing Point")
        drawGrid()
        drawFiringPointMarker()

        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.7, 0.7, 0.7)
        local hint = "Click on a colored pixel to set the firing point"
        local hintWidth = smallFont:getWidth(hint)
        love.graphics.print(hint, (screenWidth - hintWidth) / 2, gridOffsetY + cellSize * GRID_SIZE + 20)
    elseif state == "confirm" then
        drawTitle("Step 3: Confirm Your Ship")
        drawPreview()

        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.7, 0.7, 0.7)
        local info = "Firing point marked in green"
        local infoWidth = smallFont:getWidth(info)
        love.graphics.print(info, (screenWidth - infoWidth) / 2, gridOffsetY + GRID_SIZE * 4 + 30)
    end

    buttonGroup:draw()
end

function shipEditor.resize(w, h)
    screenWidth, screenHeight = w, h
    calculateGridLayout()

    if state == "draw" then
        setupDrawButtons()
    elseif state == "firing" then
        setupFiringButtons()
    elseif state == "confirm" then
        setupConfirmButtons()
    end
end

function shipEditor.getShipData()
    return {
        grid = grid,
        firingPoint = firingPoint
    }
end

return shipEditor

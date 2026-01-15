local menu = {}
local Button = require("src.button")

local font
local smallFont
local logo
local logoX, logoY, logoScale
local screenWidth, screenHeight

local MARGIN = 20
local MIN_SPACING = 40
local DEFAULT_SPACING = 60

local currentMenu = "main"
local buttonGroup = nil

local loadMainMenu
local loadSettingsMenu

local onStartCallback = nil

local settings = {
    volume = 100,
    resolutions = {
        { width = 800,  height = 600 },
        { width = 1280, height = 720 },
        { width = 1920, height = 1080 }
    },
    currentResolution = 1,
    fullscreen = false
}

local pendingSettings = {
    volume = 100,
    currentResolution = 1,
    fullscreen = false
}

local function updateLogoLayout()
    if screenHeight < 700 then
        logoScale = 0.3
    else
        logoScale = 0.5
    end
    logoX = (screenWidth - logo:getWidth() * logoScale) / 2
    logoY = MARGIN + 20
end

local function getLogoBottom()
    return logoY + logo:getHeight() * logoScale
end

local function createButtons(buttonData)
    local group = Button.newGroup()
    local buttonCount = #buttonData
    local textHeight = font:getHeight()
    local maxWidth = screenWidth - (MARGIN * 2)

    local logoBottom = getLogoBottom()
    local availableTop = logoBottom + MARGIN
    local availableBottom = screenHeight - MARGIN
    local availableHeight = availableBottom - availableTop

    local totalHeightNeeded = buttonCount * textHeight + (buttonCount - 1) * DEFAULT_SPACING
    local spacing = DEFAULT_SPACING

    if totalHeightNeeded > availableHeight then
        local heightWithoutSpacing = buttonCount * textHeight
        local availableForSpacing = availableHeight - heightWithoutSpacing
        spacing = math.max(MIN_SPACING, availableForSpacing / (buttonCount - 1))
    end

    totalHeightNeeded = buttonCount * textHeight + (buttonCount - 1) * spacing
    local startY = availableTop + (availableHeight - totalHeightNeeded) / 2
    startY = math.max(startY, availableTop)

    for i, data in ipairs(buttonData) do
        local textWidth = font:getWidth(data.text)
        local buttonFont = font
        local displayText = data.text

        if textWidth > maxWidth then
            textWidth = smallFont:getWidth(data.text)
            buttonFont = smallFont
            if textWidth > maxWidth then
                local ellipsis = "..."
                displayText = data.text
                while smallFont:getWidth(displayText .. ellipsis) > maxWidth and #displayText > 1 do
                    displayText = displayText:sub(1, -2)
                end
                displayText = displayText .. ellipsis
                textWidth = smallFont:getWidth(displayText)
            end
        end

        local buttonY = startY + (i - 1) * spacing
        local buttonX = (screenWidth - textWidth) / 2

        group:add(Button.new({
            text = displayText,
            x = buttonX,
            y = buttonY,
            font = buttonFont,
            onClick = data.onClick
        }))
    end

    return group
end

loadMainMenu = function()
    buttonGroup = createButtons({
        { text = "Start", onClick = function()
            if onStartCallback then
                onStartCallback()
            end
        end },
        {
            text = "Settings",
            onClick = function()
                currentMenu = "settings"
                loadSettingsMenu()
            end
        },
        { text = "Quit",  onClick = function() love.event.quit() end }
    })
end

loadSettingsMenu = function()
    local res = settings.resolutions[pendingSettings.currentResolution]
    local fullscreenText = pendingSettings.fullscreen and "[X] Fullscreen" or "[ ] Fullscreen"

    buttonGroup = createButtons({
        {
            text = "Volume: " .. pendingSettings.volume .. "%",
            onClick = function()
                pendingSettings.volume = (pendingSettings.volume + 10) % 110
                loadSettingsMenu()
            end
        },
        {
            text = "Resolution: " .. res.width .. "x" .. res.height,
            onClick = function()
                pendingSettings.currentResolution = pendingSettings.currentResolution % #settings.resolutions + 1
                loadSettingsMenu()
            end
        },
        {
            text = fullscreenText,
            onClick = function()
                pendingSettings.fullscreen = not pendingSettings.fullscreen
                loadSettingsMenu()
            end
        },
        {
            text = "Apply",
            onClick = function()
                settings.volume = pendingSettings.volume
                settings.currentResolution = pendingSettings.currentResolution
                settings.fullscreen = pendingSettings.fullscreen
                local newRes = settings.resolutions[settings.currentResolution]
                love.window.setMode(newRes.width, newRes.height, {
                    resizable = true,
                    fullscreen = settings.fullscreen
                })
                screenWidth = love.graphics.getWidth()
                screenHeight = love.graphics.getHeight()
                updateLogoLayout()
                loadSettingsMenu()
            end
        },
        {
            text = "Back",
            onClick = function()
                pendingSettings.volume = settings.volume
                pendingSettings.currentResolution = settings.currentResolution
                pendingSettings.fullscreen = settings.fullscreen
                currentMenu = "main"
                loadMainMenu()
            end
        }
    })
end

function menu.load(startCallback)
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    font = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 48)
    smallFont = love.graphics.newFont("assets/fonts/Jersey10-Regular.ttf", 32)
    logo = love.graphics.newImage("assets/sprites/logo/logo.png")

    Button.setDefaultFont(font)
    onStartCallback = startCallback

    updateLogoLayout()
    loadMainMenu()
end

function menu.update()
    local mx, my = love.mouse.getPosition()
    buttonGroup:update(mx, my)
end

function menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(logo, logoX, logoY, 0, logoScale, logoScale)
    buttonGroup:draw()
    love.graphics.setFont(font)
end

function menu.mousepressed(_, _, mouseButton)
    buttonGroup:checkClick(nil, nil, mouseButton)
end

function menu.getVolume()
    return settings.volume / 100
end

function menu.resize(w, h)
    screenWidth, screenHeight = w, h
    updateLogoLayout()

    if currentMenu == "main" then
        loadMainMenu()
    elseif currentMenu == "settings" then
        loadSettingsMenu()
    end
end

return menu

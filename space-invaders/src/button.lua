local button = {}
button.__index = button

local GAME_WIDTH = 800
local defaultFont = nil

function button.setDefaultFont(font)
    defaultFont = font
end

function button.new(options)
    local self = setmetatable({}, button)

    self.text = options.text or ""
    self.x = options.x or 0
    self.y = options.y or 0
    self.font = options.font or defaultFont
    self.onClick = options.onClick or function() end
    self.centered = options.centered ~= false
    self.hovered = false

    self:updateDimensions()

    return self
end

function button:updateDimensions()
    if self.font then
        self.width = self.font:getWidth(self.text)
        self.height = self.font:getHeight()
    else
        self.width = 100
        self.height = 30
    end
end

function button:setText(text)
    self.text = text
    self:updateDimensions()
end

function button:setPosition(x, y)
    self.x = x
    self.y = y
end

function button:centerHorizontally()
    self.x = (GAME_WIDTH - self.width) / 2
end

function button:update(mx, my)
    self.hovered = mx >= self.x and mx <= self.x + self.width
        and my >= self.y and my <= self.y + self.height
end

function button:draw()
    if not self.font then return end

    love.graphics.setFont(self.font)

    if self.hovered then
        love.graphics.setColor(0.7, 0.7, 0.7)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print(self.text, self.x, self.y)
end

function button:checkClick(x, y, mouseButton)
    if mouseButton == 1 and self.hovered then
        self.onClick()
        return true
    end
    return false
end

-- Button group utilities
local buttonGroup = {}
buttonGroup.__index = buttonGroup

function button.newGroup()
    local group = setmetatable({}, buttonGroup)
    group.buttons = {}
    return group
end

function buttonGroup:add(btn)
    table.insert(self.buttons, btn)
    return btn
end

function buttonGroup:clear()
    self.buttons = {}
end

function buttonGroup:update(mx, my)
    for _, btn in ipairs(self.buttons) do
        btn:update(mx, my)
    end
end

function buttonGroup:draw()
    for _, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function buttonGroup:checkClick(x, y, mouseButton)
    for _, btn in ipairs(self.buttons) do
        if btn:checkClick(x, y, mouseButton) then
            return true
        end
    end
    return false
end

function buttonGroup:layoutVertical(startX, startY, spacing, centered)
    for i, btn in ipairs(self.buttons) do
        btn.y = startY + (i - 1) * spacing
        if centered then
            btn:centerHorizontally()
        else
            btn.x = startX
        end
    end
end

return button

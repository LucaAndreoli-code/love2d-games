local colors = {}

-- Ship palette colors (indexed 1-4 for grid data)
colors.SHIP_PALETTE = {
    { name = "Red",   r = 1,    g = 0,    b = 0 },
    { name = "Blue",  r = 0,    g = 0.2,  b = 0.6 },
    { name = "Black", r = 0,    g = 0,    b = 0 },
    { name = "White", r = 1,    g = 1,    b = 1 }
}

-- Common colors
colors.WHITE = { 1, 1, 1 }
colors.BLACK = { 0, 0, 0 }
colors.GREEN = { 0, 1, 0 }
colors.YELLOW = { 1, 1, 0 }
colors.GOLD = { 1, 0.85, 0 }

-- UI colors
colors.GRID_EMPTY = { 0.1, 0.1, 0.1 }
colors.GRID_BORDER = { 0.3, 0.3, 0.3 }
colors.BUTTON_BORDER = { 0.5, 0.5, 0.5 }
colors.TEXT_HINT = { 0.7, 0.7, 0.7 }
colors.SHADOW = { 0, 0, 0, 0.7 }
colors.SLOT_BG = { 0.2, 0.2, 0.2, 0.5 }
colors.SLOT_BORDER = { 0.5, 0.5, 0.5, 0.7 }
colors.HEALTH_BAR_BG = { 0.2, 0.2, 0.2, 0.8 }

return colors

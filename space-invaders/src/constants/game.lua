local game = {}

-- Grid settings
game.GRID_SIZE = 16
game.SHIP_SCALE = 3

-- Margins
game.UI_MARGIN = 20             -- Menu/editor UI padding
game.GAMEPLAY_MARGIN = 60       -- Gameplay safe zone

-- Player settings
game.PLAYER_SPEED = 200
game.FIRE_COOLDOWN = 0.40

-- Bullet settings
game.BULLET_SPEED = 400
game.BULLET_WIDTH = 4
game.BULLET_HEIGHT = 10

-- Editor settings
game.MIN_COLORED_CELLS = 32     -- Minimum cells to proceed

-- HUD settings
game.HEALTH_BAR_WIDTH = 120
game.HEALTH_BAR_HEIGHT = 20
game.POWERUP_SLOT_SIZE = 40
game.POWERUP_SLOTS = 4

-- Background settings
game.STAR_COUNT = 150
game.STAR_SIZE_MIN = 1
game.STAR_SIZE_MAX = 4
game.STAR_SPEED_MIN = 20
game.STAR_SPEED_MAX = 100

-- Lives system
game.PLAYER_LIVES = 3
game.INVINCIBILITY_TIME = 1.5
game.RESPAWN_X = 400
game.RESPAWN_Y = 500

-- Enemy settings
game.ENEMY_SIZE = 16
game.ENEMY_HEALTH = 1
game.ENEMY_BASE_SPEED = 80
game.ENEMY_SPAWN_MIN_X = 50
game.ENEMY_SPAWN_MAX_X = 750
game.ENEMY_KILL_SCORE = 100

-- Wave settings
game.WAVE_BASE_ENEMIES = 5
game.WAVE_ENEMIES_INCREMENT = 2
game.WAVE_SPEED_MULTIPLIER = 1.1
game.WAVE_DELAY = 2.0

return game

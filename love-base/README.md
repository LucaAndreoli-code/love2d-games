# Love2D Base Template

Template modulare per progetti Love2D con struttura scalabile e pattern "init aggregator" per namespace pulito.

## Struttura

```
love-base/
├── assets/
│   ├── data/          # File dati (JSON, Lua tables, presets)
│   ├── font/          # Font personalizzati
│   ├── sounds/        # Effetti sonori e musica
│   └── sprites/       # Sprite sheets e immagini
├── shaders/           # GLSL shaders
├── src/
│   ├── constants/     # Configurazioni centralizzate (colori, dimensioni, velocità)
│   │   └── init.lua   # Aggregatore constants
│   ├── scenes/        # Scene di gioco (menu, game, pause, gameover)
│   │   └── init.lua   # Aggregatore scenes
│   ├── systems/       # Sistemi core (state machine, input handler, asset manager)
│   │   └── init.lua   # Aggregatore systems
│   ├── ui/            # Componenti UI riusabili (button, slider, panel, HUD)
│   │   └── init.lua   # Aggregatore UI
│   ├── utils/         # Utility functions (math, string, table helpers)
│   │   └── init.lua   # Aggregatore utils
│   └── init.lua       # Master loader (carica tutti i moduli)
│   └── logger.lua     # Logger a 4 livelli
├── conf.lua           # Configurazione Love2D (window, modules, identity)
└── main.lua           # Entry point minimale
└── build.lua          # File configurazione per love-build (https://github.com/ellraiser/love-build)

## Architettura

### Init Aggregator Pattern

Ogni modulo principale ha un `init.lua` che aggrega e espone i sottomoduli. Questo pattern:
- Crea un namespace pulito e gerarchico
- Permette caricamento centralizzato
- Evita collisioni di nomi globali

**Esempio `src/systems/init.lua`:**
```lua
local Systems = {}

Systems.stateMachine = require("src.systems.state_machine")
Systems.input = require("src.systems.input_handler")
Systems.assets = require("src.systems.asset_manager")

function Systems:initialize()
    -- Init centralizzato nell'ordine corretto
    self.stateMachine:init()
    self.input:init()
    self.assets:init()
end

return Systems
```

**Esempio `src/init.lua` (master loader):**
```lua
local Game = {}

Game.constants = require("src.constants.init")
Game.scenes = require("src.scenes.init")
Game.systems = require("src.systems.init")
Game.ui = require("src.ui.init")
Game.utils = require("src.utils.init")

return Game
```

**Usage:**
```lua
local Logger = require("src.logger")

function love.load()
    Game = require("src.init")  -- Carica tutto in un colpo
    Game.systems:initialize()
    
    -- Accesso pulito e gerarchico
    Logger.info("Game started", "main")
    Game.systems.stateMachine:change("menu")
end
```

### Moduli Core

#### `constants/`
Centralizza tutte le variabili di configurazione:
- Colori palette
- Dimensioni finestra/griglia
- Velocità movimento
- Margini e spacing

**Evita:**
```lua
player.speed = 200  -- Variabile sparsa nel codice
love.graphics.setColor(0.2, 0.6, 1.0)  -- Colore hardcoded
```

**Meglio:**
```lua
player.speed = Game.constants.game.playerSpeed
love.graphics.setColor(Game.constants.colors.primary)
```

#### `systems/`
Sistemi architetturali fondamentali riusabili tra progetti:

**`state_machine.lua`** - Gestione scene/stati
- Registra scene con nome
- Gestisce transizioni tra scene
- Chiama `enter()`/`exit()` quando cambi scena
- Routing di `update()`/`draw()` alla scena attiva

**`input_handler.lua`** - Input centralizzato
- Gestisce keyboard/mouse/gamepad
- Permette rebinding tasti
- Separa input da logica di gioco

**`asset_manager.lua`** - Caricamento risorse
- Cache di immagini/font/suoni
- Caricamento lazy o preload
- Evita duplicati in memoria

#### `logger.lua` (direttamente in `src/`)
Sistema di logging utilizzato ovunque. Posizionato in `src/logger.lua` invece che in `systems/` per accesso più breve e diretto:
```lua
local Logger = require("src.logger")
Logger.info("Message", "source")
```

#### `scenes/`
Scene di gioco isolate con interfaccia standard:

```lua
-- Interfaccia scene
local Scene = {}

function Scene:enter()
    -- Setup quando si entra nella scena
end

function Scene:exit()
    -- Cleanup quando si esce
end

function Scene:update(dt)
    -- Logica update
end

function Scene:draw()
    -- Rendering
end

function Scene:keypressed(key)
    -- Input handling
end

return Scene
```

Ogni scena è completamente indipendente. Lo state machine gestisce le transizioni.

#### `ui/`
Componenti UI riusabili tra scene diverse:

**Quando usare `ui/`:**
- Bottone usato in menu + pause + gameover → `ui/button.lua`
- HUD usato solo in gameplay → Può stare in `scenes/game.lua` o `ui/hud.lua`
- Slider usato in settings → `ui/slider.lua`

**Pattern component:**
```lua
-- ui/button.lua
local Button = {}
Button.__index = Button

function Button.new(x, y, width, height, text, onClick)
    local self = setmetatable({}, Button)
    -- ...
    return self
end

function Button:update()
    -- Update logic
end

function Button:draw()
    -- Rendering
end

function Button:mousepressed(x, y, button)
    -- Input handling
end

return Button
```

#### `utils/`
Helper functions generiche riusabili:

```lua
-- utils/math.lua
local MathUtils = {}

function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function MathUtils.lerp(a, b, t)
    return a + (b - a) * t
end

function MathUtils.distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

return MathUtils
```

### Logger System

Sistema di logging con 4 livelli di severità e output colorato.

**Livelli:**
- `DEBUG` (1): Informazioni dettagliate, solo con flag `--debug`
- `INFO` (2): Informazioni generali, sempre visibile
- `WARNING` (3): Avvisi, sempre visibile
- `ERROR` (4): Errori critici, sempre visibile

**Usage:**
```lua
local Logger = require("src.logger")

-- Con source tag per identificare origine
Logger.debug("Player position: 100, 200", "entities/player")
Logger.info("Level loaded successfully", "scenes/game")
Logger.warning("Low memory", "systems/assets")
Logger.error("Failed to load texture", "systems/assets")
```

**Output format:**
```
[14:32:15] INFO [scenes/game]: Level loaded successfully
[14:32:16] WARNING [systems/assets]: Low memory
[14:32:17] ERROR [systems/assets]: Failed to load texture
```

**Colori ANSI nel terminale:**
- DEBUG: Cyan (`\27[36m`)
- INFO: Green (`\27[32m`)
- WARNING: Yellow (`\27[33m`)
- ERROR: Red (`\27[31m`)

**Configurazione livello minimo:**
```lua
local Logger = require("src.logger")

-- Mostra solo WARNING ed ERROR
Logger.setLevel(Logger.LEVELS.WARNING)

-- Disabilita tutto
Logger.disable()

-- Riabilita tutto
Logger.enable()
```

**Flag `--debug`:**
Il logger controlla automaticamente la presenza del flag `--debug` negli argomenti:
```bash
love .              # currentLevel = INFO (default)
love . --debug      # currentLevel = DEBUG (se avviato tramite VSCODE)
```

Implementazione nel logger:
```lua
local function checkDebugMode()
    if arg then
        for i, v in ipairs(arg) do
            if v == "--debug" then
                return true
            end
        end
    end
    return false
end

Logger.currentLevel = checkDebugMode() and Logger.LEVELS.DEBUG or Logger.LEVELS.INFO
```

### Quando Aggiungere Moduli

**Presenti da subito nel template:**
- `constants/` - Sempre utile anche per progetti piccoli
- `systems/` - Logger e architettura base
- `utils/` - Helper comuni
- `scenes/` - Anche un gioco semplice ha almeno menu + game
- `ui/` - Per componenti riusabili

**Aggiungere quando serve:**
- `entities/` - Quando hai 3+ tipi di oggetti di gioco con logica simile
  - Player, Enemy, Bullet, Powerup, etc.
  - Utile per factory pattern e object pooling
- Sottomoduli in `systems/` man mano che servono
  - State machine quando hai 2+ scene
  - Asset manager quando hai molte risorse
  - Input handler per rebinding tasti

**Regola pratica:**
Se copi/incolli lo stesso tipo di codice 3 volte → estrai in un modulo dedicato.

## Run

```bash
# Sviluppo normale (mostra INFO, WARNING, ERROR)
love .

# Con debug logging (mostra anche DEBUG - SOLO TRAMITE VSCODE con Lua Local Debugger)
love . --debug
```

## VS Code Debug

Configurazione `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "lua-local",
            "request": "launch",
            "name": "Run LÖVE",
            "program": {
                "command": "love"
            },
            "args": ["."]
        },
        {
            "type": "lua-local",
            "request": "launch",
            "name": "Debug LÖVE",
            "program": {
                "command": "love"
            },
            "args": [".", "--debug"]
        }
    ]
}
```

Richiede estensione: **Local Lua Debugger** (tomblind)
F5 per lanciare, breakpoint funzionano su assegnazioni variabili e inizio funzioni.
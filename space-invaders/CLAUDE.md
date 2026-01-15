# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Space Invaders game built with LÖVE (Love2D) v11.5, a 2D game framework for Lua.

## Commands

**Run the game:**
```bash
love .
```

**Build for distribution:**
Uses love-build with configuration in `build.lua`. Outputs to `dist/` directory for Windows, macOS, and Linux.

## Architecture

This is a Love2D project following the standard callback pattern:

- `main.lua` - Entry point with Love2D callbacks (`love.load`, `love.update`, `love.draw`, `love.keypressed`)
- `conf.lua` - Framework configuration (window size: 1280x720, Love2D version, enabled modules)
- `build.lua` - Build/distribution settings for love-build
- `resources/` - Game assets (icons, sprites)

## Love2D Conventions

Love2D uses callback functions that the framework calls automatically:
- `love.load()` - Initialize game state, load assets
- `love.update(dt)` - Update game logic (dt = delta time in seconds)
- `love.draw()` - Render graphics each frame
- `love.keypressed(key)` - Handle keyboard input

# Eco Metroidvania - Game Design Document

## Overview
A 2D Metroidvania game with a dynamic ecosystem inspired by Rain World. Players explore an interconnected world while surviving in a living ecosystem where creatures hunt, flee, eat, and die independently of the player.

## Core Features

### 1. Player Mechanics (Metroidvania Elements)
- **Movement**: Run, jump, and dash abilities
- **Energy System**: Limited energy that depletes with dashing and regenerates over time
- **Exploration**: Unlock new areas as you gain abilities
- **Combat**: Interact with creatures - hunt or be hunted

### 2. Ecosystem System (Rain World-inspired)
- **Creature Types**:
  - **Predators**: Hunt prey and players
  - **Prey**: Flee from predators, eat food
  - **Scavengers**: Eat decaying food and weak creatures

- **Behavior States**:
  - IDLE: Resting state
  - WANDER: Random movement
  - HUNT: Chase target
  - FLEE: Escape from threats
  - EAT: Consume food/prey
  - REST: Recover energy

- **Food Chain**:
  - Creatures die and become food
  - Food decays over time
  - Energy flows through the ecosystem

### 3. Weather System
- **Weather Types**:
  - Clear: Normal conditions
  - Rain: Slightly affects behavior
  - Storm: Hazardous, creatures seek shelter
  - Fog: Reduced visibility

- **Dynamic Changes**: Weather changes periodically
- **Gameplay Impact**: Affects creature behavior and player strategy

### 4. UI & Feedback
- Energy bar and stats
- Population counter
- Weather indicator
- Ecosystem balance display
- Status messages

## Controls
- **A/D** or **Left/Right Arrow**: Move
- **Space**: Jump
- **K** or **Shift**: Dash (consumes energy)
- **E**: Interact
- **Right Click**: Spawn creature (debug)
- **Tab**: Show ecosystem status (debug)

## File Structure
```
eco_metroidvania/
├── project.godot              # Project configuration
├── scenes/
│   ├── main.tscn             # Main game scene
│   ├── player/
│   │   └── player.tscn       # Player scene
│   ├── creatures/
│   │   └── creature.tscn     # Creature scene
│   ├── environment/
│   │   └── food.tscn         # Food item scene
│   └── ui/
│       └── game_ui.tscn      # UI scene
├── scripts/
│   ├── main.gd               # Main scene controller
│   ├── player/
│   │   └── player.gd         # Player logic
│   ├── creatures/
│   │   └── creature.gd       # Creature AI
│   ├── environment/
│   │   └── food.gd           # Food decay logic
│   ├── systems/
│   │   ├── ecosystem_manager.gd  # Ecosystem management
│   │   └── weather_system.gd     # Weather control
│   └── ui/
│       └── game_ui.gd        # UI logic
└── assets/
    ├── sprites/              # Game sprites
    └── audio/                # Sound effects and music
```

## Getting Started

1. Open Godot 4.2+
2. Import the project folder
3. Open `scenes/main.tscn`
4. Press F5 to run

## Gameplay Loop

1. **Explore**: Navigate the metroidvania world
2. **Survive**: Manage energy, avoid predators
3. **Interact**: Hunt creatures or observe the ecosystem
4. **Adapt**: Weather changes affect strategy
5. **Progress**: Unlock new areas and abilities

## Ecosystem Balance

The game tracks ecosystem health:
- **Balanced** (0.5-1.5 predator/prey ratio): Healthy ecosystem
- **Declining** (<0.5): Too few predators
- **Thriving** (>1.5): Too many predators

Players can influence the ecosystem by:
- Hunting specific creatures
- Leaving food sources
- Protecting certain species

## Future Enhancements

- [ ] Add more creature types with unique behaviors
- [ ] Implement shelter system for storms
- [ ] Add player upgrades and abilities
- [ ] Create interconnected map with locked areas
- [ ] Add sleeping/shelter mechanics like Rain World
- [ ] Implement karma/progression system
- [ ] Add more weather effects
- [ ] Create diverse biomes
- [ ] Add sound effects and music
- [ ] Create sprite artwork

## Credits
Created as a demonstration of a dynamic ecosystem in a Metroidvania framework.

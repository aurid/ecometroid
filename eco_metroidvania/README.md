# Eco Metroidvania - Godot 4.2+

A 2D Metroidvania game with a dynamic ecosystem inspired by Rain World.

## Features

### Player Mechanics
- **Energy-based movement**: Dash consumes energy, regenerates over time
- **Survival mechanics**: Eat food to restore energy
- **Smooth platforming**: Jump, move, and dash controls

### Dynamic Ecosystem (Rain World-inspired)
- **Three creature types**:
  - **Predators** (Red): Hunt prey creatures
  - **Prey** (Green): Flee from predators
  - **Scavengers** (Yellow): Eat weak creatures and decaying food

- **Creature AI behaviors**:
  - IDLE: Rest and conserve energy
  - WANDER: Explore the environment
  - HUNT: Chase down prey
  - FLEE: Escape from predators
  - EAT: Consume food/creatures
  - REST: Recover energy

- **Food chain**: Dead creatures decay into food sources
- **Energy system**: All creatures drain energy over time and must eat to survive

### Weather System
- **Four weather types**:
  - Clear: Normal conditions
  - Rain: Slightly affects creature behavior
  - Storm: Hazardous weather, creatures seek shelter
  - Fog: Reduced visibility

- Weather cycles automatically and affects creature behavior modifiers

### UI Display
- Player energy bar
- Population counters (Predators | Prey | Scavengers)
- Current weather display
- Ecosystem balance indicator

## Controls

| Key | Action |
|-----|--------|
| A | Move Left |
| D | Move Right |
| Space | Jump |
| X | Dash (consumes energy) |
| E | Interact |
| Right-click | Spawn random creature |

## Installation

1. Open Godot 4.2 or later
2. Click "Import" 
3. Navigate to the `eco_metroidvania` folder
4. Select `project.godot`
5. Click "Import & Edit"
6. Press F5 to run

## How to Play

1. **Survive**: Keep your energy up by eating food (green orbs)
2. **Explore**: Move around the map using WASD and Space
3. **Dash**: Use X to dash quickly (costs energy)
4. **Observe**: Watch the ecosystem in action:
   - Predators hunt prey
   - Prey flee from predators
   - Creatures die from starvation or being eaten
   - Dead creatures become food
   - Weather changes affect behavior

5. **Interact**: Right-click anywhere to spawn additional creatures

## Project Structure

```
eco_metroidvania/
├── project.godot          # Project configuration
├── icon.svg               # Game icon
├── scripts/
│   ├── main.gd           # Main scene controller
│   ├── player/
│   │   └── player.gd     # Player controller
│   ├── creatures/
│   │   └── creature.gd   # Creature AI
│   ├── environment/
│   │   └── food.gd       # Food/decay system
│   ├── systems/
│   │   ├── ecosystem_manager.gd  # Ecosystem orchestration
│   │   └── weather_system.gd     # Weather cycles
│   └── ui/
│       └── game_ui.gd    # HUD interface
└── scenes/
    └── main.tscn         # Main game scene
```

## Ecosystem Balance

The ecosystem balance is calculated as: `predators / prey`
- **< 0.5**: Declining (too few predators)
- **0.5 - 1.5**: Balanced
- **> 1.5**: Thriving (many predators)

The system self-regulates as:
- Too many predators → prey dies out → predators starve
- Too few predators → prey multiplies → more food for predators
- Scavengers clean up weak creatures and carcasses

## Customization

Edit these values in the scripts to customize gameplay:

**Player** (`scripts/player/player.gd`):
- `speed`: Movement speed
- `jump_velocity`: Jump height
- `dash_speed`, `dash_duration`: Dash mechanics
- `energy_drain_rate`, `energy_regen_rate`: Energy system

**Creatures** (`scripts/creatures/creature.gd`):
- `max_energy`, `energy_drain_rate`: Survival mechanics
- `move_speed`, `detection_range`: Behavior parameters
- `eat_rate`: How much energy gained from eating

**Ecosystem** (`scripts/systems/ecosystem_manager.gd`):
- `max_creatures`: Population cap
- Spawn chances for each creature type

**Weather** (`scripts/systems/weather_system.gd`):
- `weather_duration`, `clear_duration`: Cycle timing
- Weather probabilities in `_change_weather()`

## License

Free to use and modify for your projects!

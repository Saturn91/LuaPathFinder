# LuaPathFinder

A lightweight pathfinding library for Lua, providing Dijkstra map generation and A* pathfinding algorithms. Perfect for games, simulations, and AI navigation in grid-based environments.

## Features

- **Dijkstra Map Generation** with radius-limited computation for efficient flow fields
- **A* Pathfinding** for finding optimal paths in grid-based maps
- **Obstacle Support** for walkable/non-walkable tiles
- **Flexible Map Structure** using 2D boolean arrays
- **Performance Optimized** with bounding box limits and early termination

## Getting Started

### Prerequisites

- Lua 5.1 or higher

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/LuaPathFinder.git
cd LuaPathFinder
```

2. Run the demo:
```bash
lua main.lua
```

## Usage

### Basic Setup

```lua
local PathFinder = require("PathFinder")

-- Create a simple 5x5 map (true = walkable)
local map = {
    {true, true, true, true, true},
    {true, false, true, false, true},
    {true, true, true, true, true},
    {true, false, true, false, true},
    {true, true, true, true, true}
}

-- Generate Dijkstra map from target position
local targetPos = {x = 3, y = 3}
local radius = 5
local dist = PathFinder.createDijsktraMap(map, targetPos, radius)

-- Find path using A*
local startPos = {x = 1, y = 1}
local endPos = {x = 5, y = 5}
local path = PathFinder.moveOne(map, startPos, endPos)

print("Path from (" .. startPos.x .. "," .. startPos.y .. ") to (" .. endPos.x .. "," .. endPos.y .. "):")
for _, step in ipairs(path) do
    print("(" .. step.x .. "," .. step.y .. ")")
end
```

### Working with Maps

Maps are represented as 2D tables where `map[x][y]` is `true` for walkable tiles and `false` for obstacles.

```lua
-- Create a 10x10 map
local map = {}
for x = 1, 10 do
    map[x] = {}
    for y = 1, 10 do
        map[x][y] = true  -- all walkable
    end
end

-- Add some obstacles
map[5][5] = false
map[3][7] = false
```

### Dijkstra Maps

Dijkstra maps compute distances from a target position, useful for flow fields and AI movement.

```lua
local dist = PathFinder.createDijsktraMap(map, {x = 5, y = 5}, 10)

-- dist[x][y] contains the distance or math.huge if unreachable
for x = 1, #map do
    for y = 1, #map[1] do
        if dist[x][y] == math.huge then
            print("Unreachable: (" .. x .. "," .. y .. ")")
        else
            print("Distance to target: " .. dist[x][y])
        end
    end
end
```

### A* Pathfinding

Find the shortest path between two points using the A* algorithm.

```lua
local path = PathFinder.moveOne(map, {x = 1, y = 1}, {x = 10, y = 10})

if #path > 0 then
    print("Path found with " .. #path .. " steps")
    for i, pos in ipairs(path) do
        print(i .. ": (" .. pos.x .. "," .. pos.y .. ")")
    end
else
    print("No path found")
end
```

## API Reference

### PathFinder.createDijsktraMap(map, targetPos, radius)

Creates a Dijkstra map for pathfinding.

#### Parameters
- `map`: 2D boolean array where `map[x][y]` is `true` for walkable tiles
- `targetPos`: Target position `{x = number, y = number}`
- `radius`: Maximum distance to consider (number)

#### Returns
- 2D number array where each cell contains the distance to the target or `math.huge` if unreachable

### PathFinder.moveOne(map, startPosition, endPosition)

Returns the full path from startPosition to endPosition using A*.

#### Parameters
- `map`: 2D boolean array where `map[x][y]` is `true` for walkable tiles
- `startPosition`: Starting position `{x = number, y = number}`
- `endPosition`: Target position `{x = number, y = number}`

#### Returns
- Array of positions `{x = number, y = number}[]` representing the path, or empty array if no path exists

## Usage Tips

### When to Use A* vs Dijkstra

- **Use A* for individual agents**: A* is ideal for finding the shortest path from one specific starting point to one specific goal. This is perfect for player characters or NPCs that need to navigate to a particular location, such as moving to a quest objective or fleeing to safety. A* guarantees the optimal path and is efficient for single queries.

Example -> player should move towards the stairs

- **Use Dijkstra for crowd control**: Dijkstra maps are better suited for scenarios where many entities need to move toward a common target. By pre-computing distances from the player's position, enemies can follow the "downhill" gradient to move toward the player without needing individual path calculations. This creates natural-looking group movement and is computationally efficient for large numbers of AI agents.

Example -> all enemies within 10 fields should move one tile towards the player.

## File Structure

```
LuaPathFinder/
├── PathFinder.lua          # Main pathfinding module
├── main.lua                # Test/demo application
└── README.md
```

## Integration into Your Project

### Option 1: Copy Module Files
Copy `PathFinder.lua` to your project and require it:

```lua
local PathFinder = require("PathFinder")
```

### Option 2: Git Submodule
Add as a git submodule:

```bash
git submodule add https://github.com/yourusername/LuaPathFinder.git lib/LuaPathFinder
```

Then require it in your code:

```lua
local PathFinder = require("lib.LuaPathFinder.PathFinder")
```

## Example Usage

This library is perfect for:

- **Game Development** (grid-based movement, AI navigation)
- **Simulations** (agent pathfinding, flow fields)
- **Puzzle Games** (optimal path calculation)
- **Robotics** (grid-based navigation algorithms)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Implemented in pure Lua for maximum compatibility
- Inspired by classic pathfinding algorithms and game development techniques
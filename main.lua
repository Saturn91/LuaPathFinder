local PathFinder = require("PathFinder")

function Simple11x11DijkstraMap()
    -- Test the Dijkstra map
    local map = {}
    for x = 1, 11 do
        map[x] = {}
        for y = 1, 11 do
            map[x][y] = true  -- all walkable
        end
    end

    local targetPos = {x = 6, y = 6}
    local radius = 5

    local dist = PathFinder.createDijsktraMap(map, targetPos, radius)

    -- Print the 11x11 grid
    DrawDijkstraMap(dist, map)
end

function DijkstraMapWithRandomObstacles()
    -- Test the Dijkstra map with 4 random obstacles in the middle
    local map = {}
    for x = 1, 11 do
        map[x] = {}
        for y = 1, 11 do
            map[x][y] = true  -- all walkable
        end
    end

    -- Add 4 random obstacles in the middle (x=4-8, y=4-8)
    math.randomseed(42)  -- for reproducibility
    local count = 0
    local obstacles = {}
    while count < 4 do
        local x = math.random(4, 8)
        local y = math.random(4, 8)
        local key = x .. "," .. y
        if not obstacles[key] then
            obstacles[key] = true
            map[x][y] = false
            count = count + 1
        end
    end

    local targetPos = {x = 6, y = 6}
    local radius = 5

    local dist = PathFinder.createDijsktraMap(map, targetPos, radius)

    -- Print the 11x11 grid X for obstacles
    DrawDijkstraMap(dist, map)
end

function DijkstraMapWithObstacles()
    -- Test the Dijkstra map with obstacles
    local map = {}
    for x = 1, 11 do
        map[x] = {}
        for y = 1, 11 do
            map[x][y] = true  -- all walkable
        end
    end

    -- Add obstacles
    for y = 1, 11 do
        map[6][y] = false  -- vertical wall in the middle
    end

    local targetPos = {x = 11, y = 6}
    local radius = 5

    local dist = PathFinder.createDijsktraMap(map, targetPos, radius)

    -- Print the 11x11 grid X for wall
    DrawDijkstraMap(dist, map)
end

function DrawDijkstraMap(dist, map)
    for y = 1, #map[1] do
        local line = ""
        for x = 1, #map do
            local d = dist[x][y]
            if type(d) == "string" then
                line = line .. d .. " "
            elseif not map[x][y] then
                line = line .. "| "
            elseif d == math.huge then
                line = line .. ". "
            else
                line = line .. tostring(d) .. " "
            end
        end
        print(line)
    end
end

function DrawSimplePath()
    local map = {}
    for x = 1, 5 do
        map[x] = {}
        for y = 1, 5 do
            map[x][y] = true  -- all walkable
        end
    end

    local startPos = {x = 1, y = 1}
    local endPos = {x = 5, y = 5}

    local path = PathFinder.moveOne(map, startPos, endPos)

    print("Full path from (" .. startPos.x .. "," .. startPos.y .. ") to (" .. endPos.x .. "," .. endPos.y .. "):")
    for _, step in ipairs(path) do
        print("(" .. step.x .. "," .. step.y .. ")")
    end

    local dist = {}

    for x = 1, 5 do
        dist[x] = {}
        for y = 1, 5 do
            dist[x][y] = math.huge
            if x == endPos.x and y == endPos.y then
                dist[x][y] = "x"
            end
        end
    end

    for _, step in ipairs(path) do
        dist[step.x][step.y] = "*"
    end

    DrawDijkstraMap(dist, map)
end

function DrawPathWithObstacles()
    local map = {}
    for x = 1, 5 do
        map[x] = {}
        for y = 1, 5 do
            map[x][y] = true  -- all walkable
        end
    end

    -- Add an obstacle
    map[2][1] = false
    
    map[2][3] = false
    map[2][4] = false

    local startPos = {x = 1, y = 1}
    local endPos = {x = 5, y = 1}

    local path = PathFinder.moveOne(map, startPos, endPos)

    print("Full path from (" .. startPos.x .. "," .. startPos.y .. ") to (" .. endPos.x .. "," .. endPos.y .. ") with obstacle:")
    for _, step in ipairs(path) do
        print("(" .. step.x .. "," .. step.y .. ")")
    end

    local dist = {}

    for x = 1, 5 do
        dist[x] = {}
        for y = 1, 5 do
            dist[x][y] = math.huge
            if x == endPos.x and y == endPos.y then
                dist[x][y] = "x"
            elseif not map[x][y] then
                dist[x][y] = "|"
            end
        end
    end

    for _, step in ipairs(path) do
        dist[step.x][step.y] = "*"
    end

    DrawDijkstraMap(dist, map)
end

function PerformanceTest()
    local mapSize = 40
    local map = {}
    for x = 1, mapSize do
        map[x] = {}
        for y = 1, mapSize do
            map[x][y] = true  -- all walkable
        end
    end

    -- block random positions
    math.randomseed(os.time())
    for i = 1, mapSize-1 do
        local x = math.random(1, mapSize)
        local y = math.random(1, mapSize)
        map[x][y] = false
    end


    local startPos = {x = 1, y = 1}
    local endPos = {x = mapSize, y = mapSize}

    local iterations = 1000
    local startTime = os.clock()
    local path
    
    for i = 1, iterations do
        path = PathFinder.moveOne(map, startPos, endPos)
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime
    
    -- Draw the last found path
    print("\nLast path from (" .. startPos.x .. "," .. startPos.y .. ") to (" .. endPos.x .. "," .. endPos.y .. "):")
    for _, step in ipairs(path) do
        print("(" .. step.x .. "," .. step.y .. ")")
    end
    
    local dist = {}
    for x = 1, mapSize do
        dist[x] = {}
        for y = 1, mapSize do
            dist[x][y] = math.huge
            if x == endPos.x and y == endPos.y then
                dist[x][y] = "x"
            end
        end
    end

    for _, step in ipairs(path) do
        dist[step.x][step.y] = "*"
    end

    DrawDijkstraMap(dist, map)

    print("Performed " .. iterations .. " pathfinding operations on a " .. mapSize .. "x" .. mapSize .. " map in " .. elapsed .. " seconds.")
    print("Average time per iteration: " .. (elapsed / iterations / 1000) .. "ms.")
end

print("Simple 11x11 Dijkstra Map:\n")
Simple11x11DijkstraMap()

print("\nDijkstra Map with Obstacles:\n")
DijkstraMapWithObstacles()

print("\nDijkstra Map with Random Obstacles:\n")
DijkstraMapWithRandomObstacles()

print("\n--- A* Tests ---")
print("\n")
DrawSimplePath()
print("\n")
DrawPathWithObstacles()

print("\n--- Performance Test ---\n")
PerformanceTest()
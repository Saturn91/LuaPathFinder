local PathFinder = {}

--[[
    Creates a Dijkstra map for pathfinding.
    @param map: The map data structure. map[x][y] 2D bool array where true indicates walkable tiles.
    @param targetPos: { x=.., y=.. } -> The target position to calculate distances from. 
    @param radius: number -> The maximum distance to consider.
    @return: A Dijkstra map with distances from the target position. map[x][y] 2D number array where each cell contains the distance to the target or math.huge if unreachable.
]]
function PathFinder.createDijsktraMap(map, targetPos, radius)
    local width = #map
    local height = #map[1] or 0
    local tx, ty = targetPos.x, targetPos.y
    local minX = math.max(1, tx - radius)
    local maxX = math.min(width, tx + radius)
    local minY = math.max(1, ty - radius)
    local maxY = math.min(height, ty + radius)
    local dist = {}
    setmetatable(dist, {
        __index = function(t, k)
            local row = {}
            setmetatable(row, {__index = function() return math.huge end})
            t[k] = row
            return row
        end
    })
    if tx >= minX and tx <= maxX and ty >= minY and ty <= maxY and map[tx] and map[tx][ty] then
        dist[tx][ty] = 0
        local queue = {{x = tx, y = ty}}
        local visited = {}
        visited[tx .. "," .. ty] = true
        while #queue > 0 do
            local current = table.remove(queue, 1)
            local cx, cy = current.x, current.y
            local cdist = dist[cx][cy]
            for _, dir in ipairs({{0, 1}, {0, -1}, {1, 0}, {-1, 0}}) do
                local nx, ny = cx + dir[1], cy + dir[2]
                if nx >= minX and nx <= maxX and ny >= minY and ny <= maxY and map[nx] and map[nx][ny] and not visited[nx .. "," .. ny] then
                    local newdist = cdist + 1
                    if newdist <= radius then
                        dist[nx][ny] = newdist
                        table.insert(queue, {x = nx, y = ny})
                        visited[nx .. "," .. ny] = true
                    end
                end
            end
        end
    end
    return dist
end

--[[
    Returns the full path from startPosition to endPosition using A*
    @param map: The map data structure. map[x][y] 2D bool array where true indicates walkable tiles.
    @param startPosition: The starting position {x=.., y=..}.
    @param endPosition: The target position {x=.., y=..}.
    @return: path: vector[] {x=.., y=..}[] full path from startPosition to endPosition.
]]
function PathFinder.moveOne(map, startPosition, endPosition)
    local width = #map
    local height = #map[1] or 0
    local start = {x = startPosition.x, y = startPosition.y}
    local goal = {x = endPosition.x, y = endPosition.y}
    if start.x == goal.x and start.y == goal.y then return {} end
    local open = {start}
    local closed = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}
    local function getKey(p) return p.x .. "," .. p.y end
    local function heuristic(a, b) return math.abs(a.x - b.x) + math.abs(a.y - b.y) end
    gScore[getKey(start)] = 0
    fScore[getKey(start)] = heuristic(start, goal)
    while #open > 0 do
        table.sort(open, function(a, b) return fScore[getKey(a)] < fScore[getKey(b)] end)
        local current = table.remove(open, 1)
        if current.x == goal.x and current.y == goal.y then
            local path = {}
            local temp = current
            while temp do
                table.insert(path, 1, {x = temp.x, y = temp.y})
                temp = cameFrom[getKey(temp)]
            end
            return path
        end
        closed[getKey(current)] = true
        for _, dir in ipairs({{0, 1}, {0, -1}, {1, 0}, {-1, 0}}) do
            local nx, ny = current.x + dir[1], current.y + dir[2]
            if nx >= 1 and nx <= width and ny >= 1 and ny <= height and map[nx][ny] then
                local neighbor = {x = nx, y = ny}
                local nkey = getKey(neighbor)
                if not closed[nkey] then
                    local tentative_g = gScore[getKey(current)] + 1
                    if not gScore[nkey] or tentative_g < gScore[nkey] then
                        cameFrom[nkey] = current
                        gScore[nkey] = tentative_g
                        fScore[nkey] = tentative_g + heuristic(neighbor, goal)
                        local inOpen = false
                        for _, p in ipairs(open) do
                            if p.x == nx and p.y == ny then inOpen = true; break end
                        end
                        if not inOpen then
                            table.insert(open, neighbor)
                        end
                    end
                end
            end
        end
    end
    return {}
end

return PathFinder
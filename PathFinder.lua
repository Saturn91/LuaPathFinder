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

local floor = math.floor

local function heapClear(heap)
    -- optional: only needed if you suspect stale heap slots being read
    for i = 1, heap.n do heap[i] = nil end
    heap.n = 0
end

local function heapPush(heap, id, fScore)
    local fid = fScore[id]
    if fid == nil then
        error("heapPush: fScore[" .. tostring(id) .. "] is nil (did you set fScore before pushing?)")
    end

    local n = heap.n + 1
    heap.n = n

    local i = n
    while i > 1 do
        local p = floor(i / 2)
        local pid = heap[p]
        if pid == nil then break end

        local pf = fScore[pid]
        -- If pf is nil, treat parent as "worse" and bubble up id.
        -- (Or you could error here to catch bugs early.)
        if pf ~= nil and pf <= fid then break end

        heap[i] = pid
        i = p
    end
    heap[i] = id
end

local function heapPop(heap, fScore)
    local n = heap.n
    if n == 0 then return nil end

    local root = heap[1]
    local last = heap[n]
    heap[n] = nil
    n = n - 1
    heap.n = n

    if n == 0 then
        heap[1] = nil
        return root
    end

    local i = 1
    while true do
        local l = i * 2
        if l > n then break end
        local r = l + 1

        local best = l
        local bestId = heap[l]
        local bestF = fScore[bestId] or math.huge

        if r <= n then
            local rId = heap[r]
            local rF = fScore[rId] or math.huge
            if rF < bestF then
                best = r
                bestId = rId
                bestF = rF
            end
        end

        local lastF = fScore[last] or math.huge
        if lastF <= bestF then break end

        heap[i] = bestId
        i = best
    end

    heap[i] = last
    return root
end

-- Manhattan heuristic
local function manhattan(x1, y1, x2, y2)
    local dx = x1 - x2; if dx < 0 then dx = -dx end
    local dy = y1 - y2; if dy < 0 then dy = -dy end
    return dx + dy
end

-- Optional reuse buffers between calls to reduce allocations
PathFinder._buf = PathFinder._buf or {
    heap = { n = 0 },
    gScore = {},
    fScore = {},
    cameFrom = {},
    openStamp = {},
    closedStamp = {},
    stamp = 0,
    xs = {},
    ys = {},
}

--[[
    Returns the full path from startPosition to endPosition using A*
    @param map: The map data structure. map[x][y] 2D bool array where true indicates walkable tiles.
    @param startPosition: The starting position {x=.., y=..}.
    @param endPosition: The target position {x=.., y=..}.
    @return: path: vector[] {x=.., y=..}[] full path from startPosition to endPosition.
]]
function PathFinder.moveOne(map, startPosition, endPosition)
    local width = #map
    local height = (map[1] and #map[1]) or 0
    if width == 0 or height == 0 then return {} end

    local sx, sy = startPosition.x, startPosition.y
    local gx, gy = endPosition.x, endPosition.y

    if sx == gx and sy == gy then return {} end

    -- quick bounds (optional, but cheap)
    if sx < 1 or sx > width or sy < 1 or sy > height then return {} end
    if gx < 1 or gx > width or gy < 1 or gy > height then return {} end
    if not map[sx][sy] or not map[gx][gy] then return {} end

    -- Buffers
    local buf = PathFinder._buf
    local heap = buf.heap
    heapClear(heap)
    local gScore = {}  -- Fresh table for each call
    local fScore = {}  -- Fresh table for each call
    local cameFrom = buf.cameFrom
    local openStamp = buf.openStamp
    local closedStamp = buf.closedStamp
    local xs = buf.xs
    local ys = buf.ys

    -- stamp trick: avoid clearing open/closed tables each call
    local stamp = (buf.stamp + 1)
    buf.stamp = stamp
    heap.n = 0

    -- id encoding: (x,y) -> id in [1..width*height]
    local function idOf(x, y) return (y - 1) * width + x end

    local startId = idOf(sx, sy)
    local goalId  = idOf(gx, gy)

    -- store x/y by id for fast neighbor decode
    xs[startId], ys[startId] = sx, sy
    xs[goalId],  ys[goalId]  = gx, gy

    gScore[startId] = 0
    local h0 = manhattan(sx, sy, gx, gy)
    fScore[startId] = h0
    cameFrom[startId] = nil

    heapPush(heap, startId, fScore)
    openStamp[startId] = stamp

    -- neighbor deltas (locals are faster than creating tables)
    local function tryNeighbor(cx, cy, cid, nx, ny)
        if nx < 1 or nx > width or ny < 1 or ny > height then return end
        if not map[nx][ny] then return end

        local nid = (ny - 1) * width + nx
        if closedStamp[nid] == stamp then return end

        local tentative = gScore[cid] + 1
        local oldG = gScore[nid]
        if oldG == nil or tentative < oldG then
            xs[nid], ys[nid] = nx, ny
            cameFrom[nid] = cid
            gScore[nid] = tentative
            fScore[nid] = tentative + manhattan(nx, ny, gx, gy)

            if openStamp[nid] ~= stamp then
                openStamp[nid] = stamp
                heapPush(heap, nid, fScore)
            else
                -- We don't decrease-key; we push duplicates and ignore stale pops via closedStamp check.
                -- (Fast + simple; still correct for A* with consistent heuristic like Manhattan on grid.)
                heapPush(heap, nid, fScore)
            end
        end
    end

    while heap.n > 0 do
        local currentId = heapPop(heap, fScore)
        if not currentId then break end

        if closedStamp[currentId] == stamp then
            -- stale entry (duplicate with worse f); skip
        else
            closedStamp[currentId] = stamp

            if currentId == goalId then
                -- reconstruct path as { {x=..,y=..}, ... }
                local path = {}
                local id = currentId
                while id do
                    local x, y = xs[id], ys[id]
                    path[#path + 1] = { x = x, y = y }
                    id = cameFrom[id]
                end

                -- reverse path in-place
                local i, j = 1, #path
                while i < j do
                    path[i], path[j] = path[j], path[i]
                    i = i + 1
                    j = j - 1
                end
                return path
            end

            local cx, cy = xs[currentId], ys[currentId]

            -- expand 4-neighbors
            tryNeighbor(cx, cy, currentId, cx, cy + 1)
            tryNeighbor(cx, cy, currentId, cx, cy - 1)
            tryNeighbor(cx, cy, currentId, cx + 1, cy)
            tryNeighbor(cx, cy, currentId, cx - 1, cy)
        end
    end

    return {}
end

return PathFinder
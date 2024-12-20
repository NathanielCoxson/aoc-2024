local inputFile = "q16.in.txt"
-------------------------------------------------------------------
-- Binary heap implementation
--
-- A binary heap (or binary tree) is a [sorting algorithm](http://en.wikipedia.org/wiki/Binary_heap).
--
-- The 'plain binary heap' is managed by positions. Which are hard to get once
-- an element is inserted. It can be anywhere in the list because it is re-sorted
-- upon insertion/deletion of items. The array with values is stored in field
-- `values`:
--
--     `peek = heap.values[1]`
--
-- A 'unique binary heap' is where the payload is unique and the payload itself
-- also stored (as key) in the heap with the position as value, as in;
--     `heap.reverse[payload] = [pos]`
--
-- Due to this setup the reverse search, based on payload, is now a
-- much faster operation because instead of traversing the list/heap,
-- you can do;
--     `pos = heap.reverse[payload]`
--
-- This means that deleting elements from a 'unique binary heap' is
-- faster than from a plain heap.
--
-- All management functions in the 'unique binary heap' take `payload`
-- instead of `pos` as argument.
-- Note that the value of the payload must be unique!
--
-- Fields of heap object:
--
--  * values - array of values
--  * payloads - array of payloads (unique binary heap only)
--  * reverse - map from payloads to indices (unique binary heap only)

local assert = assert
local floor = math.floor

local M = {}

--================================================================
-- basic heap sorting algorithm
--================================================================

--- Basic heap.
-- This is the base implementation of the heap. Under regular circumstances
-- this should not be used, instead use a _Plain heap_ or _Unique heap_.
-- @section baseheap

--- Creates a new binary heap.
-- This is the core of all heaps, the others
-- are built upon these sorting functions.
-- @param swap (function) `swap(heap, idx1, idx2)` swaps values at
-- `idx1` and `idx2` in the heaps `heap.values` and `heap.payloads` lists (see
-- return value below).
-- @param erase (function) `swap(heap, position)` raw removal
-- @param lt (function) in `lt(a, b)` returns `true` when `a < b` (for a min-heap)
-- @return table with two methods; `heap:bubbleUp(pos)` and `heap:sinkDown(pos)`
-- that implement the sorting algorithm and two fields; `heap.values` and
-- `heap.payloads` being lists, holding the values and payloads respectively.
M.binaryHeap = function(swap, erase, lt)

  local heap = {
      values = {},  -- list containing values
      erase = erase,
      swap = swap,
      lt = lt,
    }

  function heap:bubbleUp(pos)
    local values = self.values
    while pos>1 do
      local parent = floor(pos/2)
      if not lt(values[pos], values[parent]) then
          break
      end
      swap(self, parent, pos)
      pos = parent
    end
  end

  function heap:sinkDown(pos)
    local values = self.values
    local last = #values
    while true do
      local min = pos
      local child = 2 * pos

      for c = child, child + 1 do
        if c <= last and lt(values[c], values[min]) then min = c end
      end

      if min == pos then break end

      swap(self, pos, min)
      pos = min
    end
  end

  return heap
end

--================================================================
-- plain heap management functions
--================================================================

--- Plain heap.
-- A plain heap carries a single piece of information per entry. This can be
-- any type (except `nil`), as long as the comparison function used to create
-- the heap can handle it.
-- @section plainheap
do end -- luacheck: ignore
-- the above is to trick ldoc (otherwise `update` below disappears)

local update
--- Updates the value of an element in the heap.
-- @function heap:update
-- @param pos the position which value to update
-- @param newValue the new value to use for this payload
update = function(self, pos, newValue)
  assert(newValue ~= nil, "cannot add 'nil' as value")
  assert(pos >= 1 and pos <= #self.values, "illegal position")
  self.values[pos] = newValue
  if pos > 1 then self:bubbleUp(pos) end
  if pos < #self.values then self:sinkDown(pos) end
end

local remove
--- Removes an element from the heap.
-- @function heap:remove
-- @param pos the position to remove
-- @return value, or nil if a bad `pos` value was provided
remove = function(self, pos)
  local last = #self.values
  if pos < 1 then
    return  -- bad pos

  elseif pos < last then
    local v = self.values[pos]
    self:swap(pos, last)
    self:erase(last)
    self:bubbleUp(pos)
    self:sinkDown(pos)
    return v

  elseif pos == last then
    local v = self.values[pos]
    self:erase(last)
    return v

  else
    return  -- bad pos: pos > last
  end
end

local insert
--- Inserts an element in the heap.
-- @function heap:insert
-- @param value the value used for sorting this element
-- @return nothing, or throws an error on bad input
insert = function(self, value)
  assert(value ~= nil, "cannot add 'nil' as value")
  local pos = #self.values + 1
  self.values[pos] = value
  self:bubbleUp(pos)
end

local pop
--- Removes the top of the heap and returns it.
-- @function heap:pop
-- @return value at the top, or `nil` if there is none
pop = function(self)
  if self.values[1] ~= nil then
    return remove(self, 1)
  end
  return {-1,-1}
end

local peek
--- Returns the element at the top of the heap, without removing it.
-- @function heap:peek
-- @return value at the top, or `nil` if there is none
peek = function(self)
  return self.values[1]
end

local size
--- Returns the number of elements in the heap.
-- @function heap:size
-- @return number of elements
size = function(self)
  return #self.values
end

local function swap(heap, a, b)
  heap.values[a], heap.values[b] = heap.values[b], heap.values[a]
end

local function erase(heap, pos)
  heap.values[pos] = nil
end

--================================================================
-- plain heap creation
--================================================================

local function plainHeap(lt)
  local h = M.binaryHeap(swap, erase, lt)
  h.peek = peek
  h.pop = pop
  h.size = size
  h.remove = remove
  h.insert = insert
  h.update = update
  return h
end

--- Creates a new min-heap, where the smallest value is at the top.
-- @param lt (optional) comparison function (less-than), see `binaryHeap`.
-- @return the new heap
M.minHeap = function(lt)
  if not lt then
    lt = function(a,b) return (a < b) end
  end
  return plainHeap(lt)
end

--- Creates a new max-heap, where the largest value is at the top.
-- @param gt (optional) comparison function (greater-than), see `binaryHeap`.
-- @return the new heap
M.maxHeap = function(gt)
  if not gt then
    gt = function(a,b) return (a > b) end
  end
  return plainHeap(gt)
end

--================================================================
-- unique heap management functions
--================================================================

--- Unique heap.
-- A unique heap carries 2 pieces of information per entry.
--
-- 1. The `value`, this is used for ordering the heap. It can be any type (except
--    `nil`), as long as the comparison function used to create the heap can
--    handle it.
-- 2. The `payload`, this can be any type (except `nil`), but it MUST be unique.
--
-- With the 'unique heap' it is easier to remove elements from the heap.
-- @section uniqueheap
do end -- luacheck: ignore
-- the above is to trick ldoc (otherwise `update` below disappears)

local updateU
--- Updates the value of an element in the heap.
-- @function unique:update
-- @param payload the payoad whose value to update
-- @param newValue the new value to use for this payload
-- @return nothing, or throws an error on bad input
function updateU(self, payload, newValue)
  return update(self, self.reverse[payload], newValue)
end

local insertU
--- Inserts an element in the heap.
-- @function unique:insert
-- @param value the value used for sorting this element
-- @param payload the payload attached to this element
-- @return nothing, or throws an error on bad input
function insertU(self, value, payload)
  assert(self.reverse[payload] == nil, "duplicate payload")
  local pos = #self.values + 1
  self.reverse[payload] = pos
  self.payloads[pos] = payload
  return insert(self, value)
end

local removeU
--- Removes an element from the heap.
-- @function unique:remove
-- @param payload the payload to remove
-- @return value, payload or nil if not found
function removeU(self, payload)
  local pos = self.reverse[payload]
  if pos ~= nil then
    return remove(self, pos), payload
  end
end

local popU
--- Removes the top of the heap and returns it.
-- When used with timers, `pop` will return the payload that is due.
--
-- Note: this function returns `payload` as the first result to prevent
-- extra locals when retrieving the `payload`.
-- @function unique:pop
-- @return payload, value, or `nil` if there is none
function popU(self)
  if self.values[1] then
    local payload = self.payloads[1]
    local value = remove(self, 1)
    return payload, value
  end
end

local peekU
--- Returns the element at the top of the heap, without removing it.
-- @function unique:peek
-- @return payload, value, or `nil` if there is none
peekU = function(self)
  return self.payloads[1], self.values[1]
end

local peekValueU
--- Returns the element at the top of the heap, without removing it.
-- @function unique:peekValue
-- @return value at the top, or `nil` if there is none
-- @usage -- simple timer based heap example
-- while true do
--   sleep(heap:peekValue() - gettime())  -- assume LuaSocket gettime function
--   coroutine.resume((heap:pop()))       -- assumes payload to be a coroutine,
--                                        -- double parens to drop extra return value
-- end
peekValueU = function(self)
  return self.values[1]
end

local valueByPayload
--- Returns the value associated with the payload
-- @function unique:valueByPayload
-- @param payload the payload to lookup
-- @return value or nil if no such payload exists
valueByPayload = function(self, payload)
  return self.values[self.reverse[payload]]
end

local sizeU
--- Returns the number of elements in the heap.
-- @function heap:size
-- @return number of elements
sizeU = function(self)
  return #self.values
end

local function swapU(heap, a, b)
  local pla, plb = heap.payloads[a], heap.payloads[b]
  heap.reverse[pla], heap.reverse[plb] = b, a
  heap.payloads[a], heap.payloads[b] = plb, pla
  swap(heap, a, b)
end

local function eraseU(heap, pos)
  local payload = heap.payloads[pos]
  heap.reverse[payload] = nil
  heap.payloads[pos] = nil
  erase(heap, pos)
end

--================================================================
-- unique heap creation
--================================================================

local function uniqueHeap(lt)
  local h = M.binaryHeap(swapU, eraseU, lt)
  h.payloads = {}  -- list contains payloads
  h.reverse = {}  -- reverse of the payloads list
  h.peek = peekU
  h.peekValue = peekValueU
  h.valueByPayload = valueByPayload
  h.pop = popU
  h.size = sizeU
  h.remove = removeU
  h.insert = insertU
  h.update = updateU
  return h
end

--- Creates a new min-heap with unique payloads.
-- A min-heap is where the smallest value is at the top.
--
-- *NOTE*: All management functions in the 'unique binary heap'
-- take `payload` instead of `pos` as argument.
-- @param lt (optional) comparison function (less-than), see `binaryHeap`.
-- @return the new heap
M.minUnique = function(lt)
  if not lt then
    lt = function(a,b) return (a < b) end
  end
  return uniqueHeap(lt)
end

--- Creates a new max-heap with unique payloads.
-- A max-heap is where the largest value is at the top.
--
-- *NOTE*: All management functions in the 'unique binary heap'
-- take `payload` instead of `pos` as argument.
-- @param gt (optional) comparison function (greater-than), see `binaryHeap`.
-- @return the new heap
M.maxUnique = function(gt)
  if not gt then
    gt = function(a,b) return (a > b) end
  end
  return uniqueHeap(gt)
end

local function printMaze(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            io.write(m[i][j])
        end
        io.write("\n")
    end
end

local function getMaze(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local maze = {}
    for line in io.lines(filename) do
        maze[#maze+1] = {}
        for i = 1, #line do
            maze[#maze][i] = string.sub(line, i, i)
        end
    end
    return maze
end

local function getStart(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            if m[i][j] == "S" then return {i, j} end
        end
    end
    return {-1, -1}
end

local function getEnd(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            if m[i][j] == "E" then return {i, j} end
        end
    end
    return {-1, -1}
end

local function stateToString(i,j,d)
    return tostring(i)..","..tostring(j)..","..tostring(d)
end

local function getNext(v, scores)
    local min = math.huge
    local state = ""
    local idx = 1
    for i, s in pairs(v) do
        if scores[s] < min then
            min = scores[s]
            state = s
            idx = i
        end
    end
    table.remove(v, idx)
    return state
end

local function copyList(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

local function dfs(maze, s, startRow, startCol, target)
    local ROWS, COLS = #maze, #maze[1]
    local endPos = getEnd(maze)
    local v = {}
    v[stateToString(startRow, startCol, 1)] = true
    local stack = {{startRow, startCol, 1, 0, v}}
    local bestPathSquares = {}
    local dirs = {}
    dirs[0] = {-1,0}
    dirs[1] = {0, 1}
    dirs[2] = {1, 0}
    dirs[3] = {0, -1}

    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local r, c = state[1], state[2]
        local dir = state[3]
        local cost = state[4]
        local visited = state[5]
        visited[stateToString(r,c,dir)] = true
        if cost > target then goto continue
        elseif cost == target and r == endPos[1] and c == endPos[2] then
            for k, _ in pairs(visited) do
                bestPathSquares[k] = true
            end
        end

        local dr, dc = r + dirs[dir][1], c + dirs[dir][2]
        if (1 <= dr and dr <= ROWS and
            1 <= dc and dc <= COLS and
            maze[dr][dc] ~= "#" and
            not visited[stateToString(dr,dc,dir)])
        then
            local copy = copyList(visited)
            copy[stateToString(r,c,dir)] = true
            stack[#stack+1] = {dr, dc, dir, cost + 1, copy}
        end
        if not visited[stateToString(r,c,(dir+1)%4)] then
            local copy = copyList(visited)
            copy[stateToString(r,c,dir)] = true
            stack[#stack+1] = {r, c, (dir+1)%4, cost + 1000, copy}
        end
        if not visited[stateToString(r,c,(dir-1)%4)] then
            local copy = copyList(visited)
            copy[stateToString(r,c,dir)] = true
            stack[#stack+1] = {r, c, (dir-1)%4, cost + 1000, copy}
        end
        ::continue::
    end

    local mazeCopy = {}
    for i = 1, ROWS do
        mazeCopy[i] = {}
        for j = 1, COLS do
            mazeCopy[i][j] = maze[i][j]
        end
    end
    local statePattern = "(%d+),(%d+),(%d+)"
    local count = 0
    for k, _ in pairs(bestPathSquares) do
        local _, _, i, j, _ = string.find(k, statePattern)
        i = tonumber(i)
        j = tonumber(j)
        if i ~= nil and j ~= nil and mazeCopy[i][j] ~= "O" then
            mazeCopy[i][j] = "O"
            count = count + 1
        end
    end

    for i, _ in pairs(mazeCopy) do
        for j, _ in pairs(mazeCopy[i]) do
            io.write(mazeCopy[i][j])
        end
        io.write("\n")
    end
    print(count)
end

local function backtrack(maze, s, prev, target)
    local ROWS, COLS = #maze, #maze[1]
    local endPos = getEnd(maze)
    local stack = {}
    local points = {}
    local starts = {}

    local mazeCopy = {}
    for i = 1, ROWS do
        mazeCopy[i] = {}
        for j = 1, COLS do
            mazeCopy[i][j] = maze[i][j]
        end
    end

    for i = 0, 3 do
        if s[stateToString(endPos[1],endPos[2],i)] == target then stack[#stack+1] = stateToString(endPos[1],endPos[2],i) end
    end
    local statePattern = "(%d+),(%d+),(%d+)"
    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local _, _, i, j, d = string.find(state, statePattern)
        i = tonumber(i)
        j = tonumber(j)
        d = tonumber(d)

        if i == nil or j == nil or d == nil then goto continue end

        mazeCopy[i][j] = "O"

        if d == 0 and s[stateToString(i+1,j,d)] ~= nil and s[state] > s[stateToString(i+1,j,d)] then
            stack[#stack+1] = stateToString(i+1,j,d)
        elseif d == 1 and s[stateToString(i,j-1,d)] ~= nil and s[state] > s[stateToString(i,j-1,d)] then
            stack[#stack+1] = stateToString(i,j-1,d)
        elseif d == 2 and s[stateToString(i-1,j,d)] ~= nil and s[state] > s[stateToString(i-1,j,d)] then
            stack[#stack+1] = stateToString(i-1,j,d)
        elseif d == 3 and s[stateToString(i,j+1,d)] ~= nil and s[state] > s[stateToString(i,j+1,d)] then
            stack[#stack+1] = stateToString(i,j+1,d)
        end
        if s[stateToString(i,j,(d+1)%4)] ~= nil and s[state] > s[stateToString(i,j,(d+1)%4)] then
            stack[#stack+1] = stateToString(i,j,(d+1)%4)
        end
        if s[stateToString(i,j,(d-1)%4)] ~= nil and s[state] > s[stateToString(i,j,(d-1)%4)] then
            stack[#stack+1] = stateToString(i,j,(d-1)%4)
        end

        ::continue::
    end

    local count = 0
    for i, _ in pairs(mazeCopy) do
        for j, _ in pairs(mazeCopy[i]) do
            if mazeCopy[i][j] == "O" then count = count + 1 end
            io.write(mazeCopy[i][j])
        end
        io.write("\n")
    end
    print("Part 2:", count)
end

local function lowestScore(maze)
    local ROWS, COLS = #maze, #maze[1]
    local start = getStart(maze)
    local endPos = getEnd(maze)
    local comp = function(a,b)
        return a[1] < b[1]
    end
    local unvisited = M.minHeap(comp)
    local visited = {}
    local graph = {}
    local score = {}
    local prev = {}
    for i, _ in pairs(maze) do
        for j, _ in pairs(maze[i]) do
            if maze[i][j] == "#" then goto continue end
            for d = 0, 3 do
                visited[stateToString(i,j,d)] = false
                graph[stateToString(i,j,d)] = {}
                score[stateToString(i,j,d)] = math.huge
                if     d == 0 and (1 <= i - 1 and i - 1 <= ROWS) and maze[i-1][j] ~= "#" then
                    table.insert(graph[stateToString(i,j,d)], stateToString(i-1,j,d))
                elseif d == 1 and (1 <= j + 1 and j + 1 <= COLS) and maze[i][j+1] ~= "#" then
                    table.insert(graph[stateToString(i,j,d)], stateToString(i,j+1,d))
                elseif d == 2 and (1 <= i + 1 and i + 1 <= ROWS) and maze[i+1][j] ~= "#" then
                    table.insert(graph[stateToString(i,j,d)], stateToString(i+1,j,d))
                elseif d == 3 and (1 <= j - 1 and j - 1 <= COLS) and maze[i][j-1] ~= "#" then
                    table.insert(graph[stateToString(i,j,d)], stateToString(i,j-1,d))
                end
                table.insert(graph[stateToString(i,j,d)], stateToString(i,j,(d+1)%4))
                table.insert(graph[stateToString(i,j,d)], stateToString(i,j,(d-1)%4))
            end
            ::continue::
        end
    end
    score[stateToString(start[1],start[2],1)] = 0
    prev[stateToString(start[1],start[2],1)] = {}
    insert(unvisited, {0, stateToString(start[1], start[2], 1)})
    visited[stateToString(start[1],start[2],1)] = true

    local statePattern = "(%d+),(%d+),(%d+)"
    local iter = 0
    while size(unvisited) > 0 do
        iter = iter + 1
        local state = pop(unvisited)
        if state == nil or state[1] == nil or state[2] == nil then goto continue end

        local _, _, _, _, d = string.find(state[2], statePattern)
        local cost = state[1]

        for _, adj in pairs(graph[state[2]]) do
            local _, _, _, _, ad = string.find(adj, statePattern)
            if not visited[adj] then
                if d ~= ad then
                    if cost + 1000 <= score[adj] then
                        score[adj] = cost + 1000
                        if prev[adj] == nil then prev[adj] = {} end
                        prev[adj][#prev[adj]+1] = state[2]
                    end
                else
                    if cost + 1 <= score[adj] then
                        score[adj] = cost + 1
                        if prev[adj] == nil then prev[adj] = {} end
                        prev[adj][#prev[adj]+1] = state[2]
                    end
                end
                insert(unvisited, {score[adj], adj})
                visited[adj] = true
            end
        end
        ::continue::
    end
    local min = math.huge
    for i = 0, 3 do
        min = math.min(min, score[stateToString(endPos[1],endPos[2],i)])
    end
    --print(dfs(maze, score, start[1], start[2], min))
    backtrack(maze, score, prev, min)
    print("Part 1:", min)
end

local maze = getMaze(inputFile)
--print(cheapestPath(maze))
lowestScore(maze)

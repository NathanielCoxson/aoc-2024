local function get_numbers(filename)
    local file = io.open(filename, "r")
    local numbers = {}
    if file ~= nil then
        io.input(file)
    else
        print("File does not exist")
        return numbers
    end

    for line in io.lines() do
        for num in string.gmatch(line, "[^%s]+") do
            table.insert(numbers, tonumber(num))
        end
    end

    local output = {}
    output["left"] = {}
    output["right"] = {}

    for i, n in pairs(numbers) do
        if (i % 2 == 0) then
            table.insert(output["right"], n)
        else
            table.insert(output["left"], n)
        end
    end

    table.sort(output["left"])
    table.sort(output["right"])

    return output
end

local numbers = get_numbers("q1.in.txt")

local function get_distances_sum()
    local distances_sum = 0
    for i, n in pairs(numbers["left"]) do
        local left = n
        local right = numbers["right"][i]
        distances_sum = distances_sum + math.abs(right - left)
    end
    return distances_sum
end

print(get_distances_sum())

local function get_similarity_score(nums)
    local counts = {}
    for _, n in pairs(nums["right"]) do
        if counts[n] == nil then counts[n] = 0 end
        counts[n] = counts[n] + 1
    end

    local similarity_score = 0
    for _, n in pairs(nums["left"]) do
        if counts[n] ~= nil then
            similarity_score = similarity_score + (n * counts[n])
        end
    end
    return similarity_score
end

print(get_similarity_score(numbers))

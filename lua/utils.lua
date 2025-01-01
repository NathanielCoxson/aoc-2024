local utils = {}

function utils.getData(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = line
    end
    return lines
end

function utils.copyTable(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

return utils

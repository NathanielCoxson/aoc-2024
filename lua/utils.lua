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

function utils.copyTable2D(t)
    local copy = {}
    for i, _ in pairs(t) do
        copy[i] = {}
        for j, _ in pairs(t[i]) do
            copy[i][j] = t[i][j]
        end
    end
    return copy
end

function utils.printTable2D(args)
    for i, _ in pairs(args.t) do
        for j, _ in pairs(args.t[i]) do
            io.write(args.t[i][j])
            if j ~= #args.t[i] then io.write(args.delimiter) end
        end
        io.write("\n")
    end
end

return utils

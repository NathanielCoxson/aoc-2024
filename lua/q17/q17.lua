local inputFile = "q17.in.txt"

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local A, B, C = 0, 0, 0
    local program = {}
    local registerPattern = "Register ([ABC]): (%d+)"
    for line in io.lines(filename) do
        if line:sub(1,1) == "R" then
            local _, _, R, N = line:find(registerPattern)
            N = tonumber(N)
            if type(N) == "number" then
                if R == "A" then A = N
                elseif R == "B" then B = N
                elseif R == "C" then C = N
                end
            end
        elseif line:sub(1,1) == "P" then
            for opcode, operand in line:gmatch("(%d+)[^%d]+(%d+)") do
                program[#program+1] = {tonumber(opcode), tonumber(operand)}
            end
        end
    end
    return {A, B, C, program}
end

local function getComboOperand(A, B, C, operand)
    if (0 <= operand and operand <= 3) or operand == 7 then return operand
    elseif operand == 4 then return A
    elseif operand == 5 then return B
    elseif operand == 6 then return C
    end
end

local function runProgram(input)
    local A, B, C = input[1], input[2], input[3]
    local program = input[4]
    local output = {}
    local ptr = 1

    while 1 <= ptr and ptr <= #program do
        local instruction = program[ptr]
        local opcode, operand = instruction[1], instruction[2]
        local jumped = false

        if     opcode == 0 then
            local comboOperand = getComboOperand(A, B, C, operand)
            A = math.floor(A / (2^comboOperand))
        elseif opcode == 1 then
            B = B ~ operand
        elseif opcode == 2 then
            local comboOperand = getComboOperand(A, B, C, operand)
            B = comboOperand % 8
        elseif opcode == 3 then
            if A ~= 0 then
                ptr = operand + 1
                jumped = true
            end
        elseif opcode == 4 then
            B = B ~ C
        elseif opcode == 5 then
            local comboOperand = getComboOperand(A, B, C, operand)
            output[#output+1] = comboOperand % 8
        elseif opcode == 6 then
            local comboOperand = getComboOperand(A, B, C, operand)
            B = math.floor(A / (2^comboOperand))
        elseif opcode == 7 then
            local comboOperand = getComboOperand(A, B, C, operand)
            C = math.floor(A / (2^comboOperand))
        end

        if not jumped then ptr = ptr + 1 end
        --print(ptr, opcode, operand, A, B, C)
    end

    print("Output:")
    print("A: ", A, "B: ", B, "C: ", C)
    for i, n in pairs(output) do
        io.write(n)
        if i ~= #output then io.write(",") end
    end
    print()

    return output
end

getInput(inputFile)
runProgram(getInput(inputFile))

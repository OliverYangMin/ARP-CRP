Master = {}
Master.__index = Master

function Master:new(name)
    local self = {lp = CreateLP(), obj = {}, solution = {}, name = name or 'MasterProblem'}
    setmetatable(self, Master)
    return self
end 


function Master:WriteLP()
    self:SetObjFunction()
    self:AddConstraint()
end 

function Master:lpSolve()
    self.result_type = 'lp'
    if SolveLP(self.lp) == 0 then
        print('Problem Be Solved Successful')
        return 0
    else
        print('Problem May Be Infeasible')
        return 1
    end 
end 

function Master:cplexSolve()
    WriteLP(self.lp, self.name .. '.mps')
    os.remove(self.name .. "_solution.sol")
    os.execute("cplex.exe -c \"read " .. self.name .. ".mps\" \"opt\" \"write " .. self.name .. "_solution.sol\" \"quit\"")
    self.result_type = 'cplex'
    local sign
    if io.open(self.name .. '_solution.sol') then
        print('Problem Be Solved Successful')
        sign = 0
    else
        print('Problem May Be Infeasible')
        sign = 1
    end 
    io.close()
    return sign
end 

function Master:SetObjFunction()
    for f,flight in pairs(flights) do -- no double flight cancel: both cancel or single cancel
        if flight.impacted then 
            self.obj[#self.obj+1] = PENALTY[1] - PENALTY[2] - 120 * 25 + (PENALTY[6] - 1.5) * flight.pass
        else
            self.obj[#self.obj+1] = PENALTY[1] + PENALTY[6] * flight.pass
        end 
    end 
    ---the cost for every route has been found
    for i=1,#columns do
        self.obj[#self.obj+1] = columns[i]:getCost()
    end 
    SetObjFunction(self.lp, self.obj, 'min')
end 
function Master:AddConstraint()
    local coeff, changed = {}, {}
    for j=1,#self.obj do coeff[j] = 0 end 
    local function resetCoeff()
        for i=1,#changed do
            coeff[changed[i]] = 0
        end 
        changed = {}
    end  
    ---constraint 1 every flight been execute by only one route or be canceled
    for i=1,#flights do
        coeff[i] = 1
        changed[#changed+1] = i
        for j=1,#columns do
            if columns[j]:isInclude(i) then 
                coeff[#flights + j] = 1
                changed[#changed+1] = #flights + j
            end 
        end 
        AddConstraint(self.lp, coeff, '=', 1)
        resetCoeff()
    end
    ---constraint 2 every flight been execute by only one route or be canceled
    for cid,craft in pairs(crafts) do
        for j=1,#columns do 
            if columns[j].craft == cid then 
                coeff[#flights+j] = 1
                changed[#changed+1] = #flights + j
            end 
        end 
        AddConstraint(self.lp, coeff, '<=', 1)
        resetCoeff()
    end 
end 

function Master:setDuals()
    local duals = {GetDuals(self.lp)}
    for f,flight in ipairs(flights) do
        flight.dual = duals[f]
    end 
    local i = 1
    for c,craft in pairs(crafts) do
        craft.dual = duals[#flights+i]
        i = i + 1
    end
end 

function Master:updateSolution()
    local var = {}
    if self.result_type == 'cplex' then 
        local i, inputf = 1, io.open(self.name .. "_solution.sol")
        if inputf then 
            for line in inputf:lines() do
                if not self.objective then
                    self.objective = string.match(line, "objectiveValue=\"([-%d%.e]+)\"")
                end
                if not var[i] then
                    var[i] = tonumber(string.match(line, "variable.+value=\"([-%d%.e]+)\""))
                    if var[i] then i = i + 1 end
                end
            end
            inputf:close()
        else
            error('open solution.sol with error')
        end 
    elseif self.result_type == 'lp' then
        self.objective = GetObjective(self.lp)
        self.var = {GetVariables(self.lp)}
    end 
end 

function Master:print()
    for i=1,#flights do
        if math.abs(self.var[i] - 1) < 0.0001 then
            print('Flight ', i, ' be canceled' )
        end 
    end 
    
    self.result = {}
    for i=1,#columns do
        if math.abs(self.var[#flights+i] - 1) < 0.0001 then
            table.insert(self.result, columns[i])
            --print('Craft ', columns[i].craft, ' run the route ', table.concat(columns[i],'-') )
        end 
    end 
    print(table.concat(self.var, '-'))
end 

function Master:solveInteger()
    for i=1,#self.obj do
        SetBinary(self.lp, i)
    end
    if self:cplexSolve() ~= 0 then
        error('Infeasible')
    end 
end 
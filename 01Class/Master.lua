Master = {}
Master.__index = Master

function Master:new()
    local self = {lp = CreateLP(), obj = {}, solution = {}}
    setmetatable(self, Master)
    return self
end 

function Master:SetObjFunction()
    for f,flight in ipairs(flights) do
        self.obj[#self.obj+1] = P[1] + (P[6] - 1.5) * flights.pass
    end 
    ---the cost for every route has been found
    for i=1,#columns do
        obj[#obj+1] = columns[i].cost
    end 
    SetObjFunction(self.lp, obj, 'min')
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
            if columns[j]:isIn(flights[i]) then 
                coeff[#flights + j] = 1
                changed[#changed+1] = #flights + 1
            end 
        end 
        AddConstraint(self.lp, coeff, '=', 1)
        resetCoeff()
    end
    
    for cid,craft in pairs(crafts) do
        for j=1,#columns do 
            if columns[j].craft == cid then 
                coeff[#flights+j] = 1
                changed[#changed+1] = #flights + 1
            end 
        end 
        AddConstraint(master, coeff, '<=', 1)
        resetCoeff()
    end 
    
    for t=13*60,20*60,10 do
        for i=1,#columns do
            coeff[i] = slot_used(columns[i], t)
            changed[#changed+1] = i
        end 
        AddConstraint(self.lp, coeff, '<=', slot_capacity(t))
        resetCoeff()
    end 
    
    for d=1,7 do
        for i=1,#columns do
            coeff[#flights + i] = columns[i].cut
            changed[#changed+1] = #flights + i
        end 
        AddConstraint(master, coeff, '<=', math.floor(0.05 * dayFlights[d]))
        resetCoeff()
        
        for i=1,#flights do
            if flights[i].date == d then
                coeff[i] = 1
                changed[#changed+1] = i
            end
        end 
        AddConstraint(master, coeff, '<=', math.floor(0.1 * dayFlights[d]))    
        resetCoeff()
    end
end 

function Master:WriteLP()
    self:SetObjFunction()
    self:AddConstraint()
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

function Master:solveInteger()
    for i=1,#self.obj do
        SetBinary(self.lp, i)
    end
    if self:cplexSolve() ~= 0 then
        error('Infeasible')
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
        var = {GetVariables(self.lp)}
    end    
end 

function Master:setDuals()
    for f,flight in ipairs(flights) do
        flight.dual = self.duals[f]
    end 
    for c,craft in pairs(aircrafts) do
        craft.dual = self.duals[#flights+c]
    end 
    cut_price = self.duals[#self.duals]
end 

function Master:solveSubproblem()
    local routes = {}
    for c,craft in pairs(crafts) do
        local route = craft:generateRoute()
        if route.cost < -0.001 then 
            routes[#routes+1] = route
        end
    end 
    return routes 
end 
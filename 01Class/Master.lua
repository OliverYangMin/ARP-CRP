Master = {}
Master.__index = Master

function Master:new(name)
    local self = {lp = CreateLP(), obj = {}, solution = {}, name = name or 'MasterProblem'}
    setmetatable(self, Master)
    return self
end 

function Master:solveSubproblem()
    local not_opt   
    for c,craft in pairs(crafts) do
        local routes = craft:generateRoutes()
        if not routes:isEmpty() then
            not_opt = true
            for i=1,5 do
                local route = routes:delMin()
                local column = route:to_column()
--                for j=1,#columns do
--                    local k = 1
--                    while k <= #columns[j] do
--                        if not (column[k] and columns[j][k] == column[k]) then
--                            break
--                        end 
--                        k = k + 1
--                    end 
--                    if k > #columns then
--                        error('there two same column')
--                    end 
--                end 
                columns[#columns+1] = column
                if routes:isEmpty() then break end 
            end 
        end 
    end 
    return not_opt
end 

function Master:updateSolution()
    self.var = {}
    if self.result_type == 'cplex' then 
        
        self.duals = {}
        local i, j, inputf = 1, 1, io.open(self.name .. "_solution.sol")
        if inputf then 
            for line in inputf:lines() do
                if not self.objective then
                    self.objective = string.match(line, "objectiveValue=\"([-%d%.e]+)\"")
                end
                
                if not self.duals[j] then
                    self.duals[j] = tonumber(string.match(line, "constraint.+dual=\"([-%d%.e]+)\""))
                    if self.duals[j] then j = j + 1 end 
                end 
                if not self.var[i] then
                    self.var[i] = tonumber(string.match(line, "variable.+value=\"([-%d%.e]+)\""))
                    if self.var[i] then i = i + 1 end
                end
            end
            inputf:close()
        else
            error('open solution.sol with error')
        end 
    elseif self.result_type == 'lp' then
        self.objective = GetObjective(self.lp)
        self.var = {}
        for i=1,#self.obj do
            self.var[i] = GetVariable(self.lp, i)
        end 
        
    end 
end 


function Master:setDuals()
    self.duals = self.duals or {GetDuals(self.lp)}
    for f,flight in ipairs(flights) do
        flight.dual = self.duals[f]
    end 
    local i = 1
    for c,craft in pairs(crafts) do
        craft.dual = self.duals[#flights+i]
        i = i + 1
    end
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

--function Master:print()
--    for i=1,#flights do
--        if math.abs(self.var[i] - 1) < 0.0001 then
--            print('Flight ', i, ' be canceled' )
--        end 
--    end 
    
--    self.result = {}
--    for i=1,#columns do
--        if math.abs(self.var[#flights+i] - 1) < 0.0001 then
--            table.insert(self.result, columns[i])
--            --print('Craft ', columns[i].craft, ' run the route ', table.concat(columns[i],'-') )
--        end 
--    end 
--    print(table.concat(self.var, '-'))
--end 

function Master:integerSolve()
    for i=1,#self.obj do
        SetBinary(self.lp, i)
    end
    if self:lpSolve() ~= 0 then
        error('Infeasible')
    end 
end 
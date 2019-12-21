Evaluator = {}
Evaluator.__index = Evaluator 

PENALTY = {2000, 1300, 1800, 400, 25, 10, 1, 1, 1200, 800, 1200, 800, 300, 600, 400, 500, 800, 500}
local TYPE_TYPE = {{0,1,2,3,5}, {1,0,1.5,2.5,4}, {2,1.5,0,2,3.5}, {3,2.5,2,0,2}, {5,4,3.5,2,0}}

function Evaluator:new()
    local self = {}
    setmetatable(self, Evaluator)
    return self
end 

function Evaluator:passenger_delay_coeff(delay)
    if delay == 0 then
        return 0
    elseif delay <= 60 then
        return 1
    elseif delay <= 120 then
        return 1.5
    elseif delay <= 240 then
        return 2
    elseif delay <= 720 then
        return 3
    elseif delay <= 1440 then
        return 5
    else
        error('This flight should be canceled')
    end 
end 

function Evaluator:getDelayCost(flight, delay, craft)
    local cost = 0
    if delay > 0 then
        if flight.impacted then 
           cost = cost + PENALTY[5] * delay + PENALTY[7] * self:passenger_delay_coeff(delay + 120) * math.min(flight.pass, craft.seat) 
        else
            cost = cost + PENALTY[2] + PENALTY[5] * delay + PENALTY[7] * self:passenger_delay_coeff(delay) * math.min(flight.pass, craft.seat) 
        end 
    end 
    return cost
end 

function Evaluator:getCraftSwapCost(flight, craft)
    local cost = 0
    if flight.old ~= craft.id then
        if flight.tp ~= craft.tp then
            cost = cost + PENALTY[4] * TYPE_TYPE[craft.tp][flight.tp]
        end 
        cost = cost + PENALTY[6] * math.max(0, flight.pass - craft.seat)
    end 
    return cost 
end 

function Evaluator:getBaseChangeCost(flight1, flight2, base)
    local cost = 0
    for j=1,flight2.date - flight1.date do
        if flight1.port2 ~= base[flight1.date+j-1] then
            cost = cost + PENALTY[3]
        end
    end 
    return cost 
end 



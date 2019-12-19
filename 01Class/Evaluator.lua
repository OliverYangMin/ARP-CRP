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

function Evaluator:getCost(column)
    local cost, time = 0, 0
    local craft = crafts[column.craft]
    for i=#column-1,1,-1 do
        local flight = flights[column[i]]
        local delay = math.max(0, time - flight.time1)
        
        ---航班延误：延误班次=2，延误时间=5，乘客延误时间=7 ---换机:机型更换=4, 乘客减少=6
        cost = cost + self:getDelayCost(flight, delay, craft) + self:getCraftSwapCost(flight, craft)
      
        --- 联程=10
--        if flight.double then
--            if i == #column or column[i+1] ~= flight.double then
--                cost = cost + PENALTY[10]
--            end 
--        end 
        
        ---驻地=3
--        if flight.date < flights[self[i+1]].date then
--            if flight.port2 ~= craft.base[flight.date] then
--                cost = cost + PENALTY[3]
--            end 
--        end 
        time = flight.time2 + delay + ports[flight.port2][craft.tp]
    end
    
    if flights[column[1]].port2 ~= craft.base then
        return cost + PENALTY[3]
    end 
    return cost 
end 
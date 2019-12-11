Evaluator = {}
Evaluator.__index = Evaluator 


local PENALTY = {2000, 1300, 1800, 400, 25, 10, 1, 1, 1200, 800, 1200, 800, 300, 600, 400, 500, 800, 500}
local TYPE_TYPE = {{0,1,2,3,5},
        {1,0,1.5,2.5,4},
        {2,1.5,0,2,3.5},
        {3,2.5,2,0,2},
        {5,4,3.5,2,0}}

function Evaluator:new()
    local self = {}
    setmetatable(self, Evaluator)
    return self
end 

function Evaluator:passenger_delay_coeff(delay)
    if delay <= 60 then
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

function Evaluator:getCost(column)
    local cost, time = 0
    local craft = crafts[column.craft]
    for i=1,#column do
        local flight = flights[column[i]]
        local delay = math.max(0, time - flight.time1)
        
        ---航班延误：延误班次=2，延误时间=5，乘客延误时间=7
        if delay > 0 then
            cost = cost + PENALTY[2] + delay * PENALTY[5] + passenger_delay_coeff(delay) * math.min(flight.pass, craft.seat) * PENALTY[7]
        end 
        
        ---换机:机型更换=4, 乘客减少=6
        if column.craft ~= flight.old then
            cost = cost + math.max(0, flight.pass - craft.seat) * PENALTY[6]
            if craft.tp ~= flight.tp then
                cost = cost + PENALTY[4] * TYPE_TYPE[craft.atp][flight.atp] 
            end
        end 
        
        --- 联程=10
        if flight.double then
            if i == #column or column[i+1] ~= flight.double then
                cost = cost + PENALTY[10]
            end 
        end 
        
        ---驻地=3
--        if flight.date < flights[self[i+1]].date then
--            if flight.port2 ~= craft.base[flight.date] then
--                cost = cost + PENALTY[3]
--            end 
--        end 
        time = flight.time2 + delay + ports[flight.port2][craft.tp]
    end
    
    do 
        local terminal = #column > 0 and flights[column[#column]].port2 or craft.start 
        if terminal ~= craft.base[1] then
            cost = cost + PENALTY[3]
        end 
    end
    return cost
end 

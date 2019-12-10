Column = {}
Column.__index = Column 

function Column:new(craft)
    local self = {craft = craft}
    setmetatable(self, Column)
    return self
end 

function passenger_delay_coeff(delay)
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

function Column:getCost()
    local cost, time = 0, 0
    local craft = crafts[self.craft]
    for i=1,#self do
        local flight = flights[self[i].fid]
        local delay = math.max(0, time - flight.time1)
        
        ---航班延误：延误班次=2，延误时间=5，乘客延误时间=7
        if delay > 0 then
            cost = cost + PENALTY[2] + delay * PENALTY[5] + passenger_delay_coeff(delay) * math.min(flight.pass, craft.seat) * PENALTY[7]
        end 
        
        ---换机:机型更换=4, 乘客减少=6
        if self.craft ~= flight.old then
            cost = cost + math.max(0, flight.pass - craft.seat) * PENALTY[6]
            if craft.atp ~= flight.atp then
                cost = cost + PENALTY[4] * TYPE_TYPE[craft.atp][flight.atp] 
            end
        end 
        
        --- 联程=10
--        if flight.double then
--            if i == #self or flights[self[i+1]].id ~= flight.double then
--                cost = cost + PENALTY[10]
--            end 
--        end 
        ---驻地=3
--        if flight.date < flights[self[i+1].fid].date then
--            if flight.port2 ~= craft.base[flight.date] then
--                cost = cost + PENALTY[3]
--            end 
--        end 
        self[i].time = flight.time1 + delay
        time = flight.time2 + ports[flight.port2][self.tp]
    end 
    if flights[self[#self].fid].port2 ~= crafts[self.craft].base[1] then
        cost = cost + PENALTY[3]
    end 
end 

function Column:isInboundSlot(time)
    for i=1,#self do
        if flights[self[i].fid].port2 == 'ZUUU' and self[i].time >= time and self[i].time < time + 10 then
            return true
        end 
    end 
    return false
end 
Flight = {}
Flight.__index = Flight

function Flight:new(row)
    local self = {id = row[1], date = row[2] - 24, hbh = row[3], port1 = row[4], port2 = row[5], time1 = row[6] - 1440 * 24, time2 = row[7] - 1440 * 24,  old = row[9], tp = row[10], pass = row[11], revenue = row[12], water = row[13], atp = {row[14], row[15], row[16], row[17], row[18]}}
    setmetatable(self, Flight)
--    if (self.port1 == 'ZUUU' and self.time1 > 60 * 13 and self.time1 <= 60 * 20) or (self.port2 == 'ZUUU' and self.time2 > 60 * 13 and self.time2 <= 60 * 20) then
--        self.dis = true
--    end 
    return self
end     

--function Flight:isDelayFeasible(delay)
--    return delay <= 1440 and ports[self.port1]:isTimeFeasible(self.time1 + delay) and ports[self.port2]:isTimeFeasible(self.time2 + delay)
--end 

--function Flight:getDelayCost(delay)
--    local function passDelayCoeff(delay)
--        if delay > 0 then
--            local box = {0, 60, 120, 240, 720, 1440}
--            local coeff = {1, 1.5, 2, 3, 5}
--            for i=2,#box do   
--                if delay > box[i-1] and delay <= box[i] then
--                    return coeff[i-1]
--                end 
--            end 
--            error('This flight should be canceled')
--        end 
--        return 0
--    end 
--    local cost = 0
--    if delay > 0 then
--        cost = cost + PENALTY[2] + PENALTY[5] * delay + passDelayCoeff(delay) * self.pass
--    end 
--end 

--function Flight:getCraftSwapCost(craft_id)
--    local cost = 0

--    if self.id ~= craft_id then
--        if self.tp ~= crafts[craft_id].tp then
--            cost = cost + PENALTY[4] * TYPE_TYPE[crafts[craft_id].tp][self.tp]
--        end 
--        cost = cost + PENALTY[6] * math.max(0, self.pass - crafts[craft_id].seat)
--    end 
--    return cost 
--end 

--function Flight:generateDelaySet()
--    for i=10, 20 * 60,10 do
--        local flight = DeepCopy(self)
--        flight.time1, flight.time2 = flight.time1 + i, flight.time2 + i
--    end 
--end 
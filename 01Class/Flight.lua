Flight = {}
Flight.__index = Flight

function Flight:new(id, row)
    local self = {id = id, date = row[3] - 24, port1 = row[4], port2 = row[5], time1 = row[6] - 1440 * 24, time2 = row[7] - 1440 * 24,  old = row[9], tp = row[10], pass = row[11], revenue = row[12], water = row[13], atp = {row[14], row[15], row[16], row[17], row[18]}}
    if self.port1 == 'ZUUU' and self.time1 >= 60 * 13 and self.time1 < 60 * 20 then
        self.dis = true
        self.time1, self.time2 = self.time1 + 60, self.time2 + 60
        outbound_disrupted = outbound_disrupted + 1
    elseif self.port2 == 'ZUUU' and self.time2 >= 60 * 13 and self.time2 < 60 * 20 then
        self.dis = true
        self.time1, self.time2 = self.time1 + 60, self.time2 + 60
        inbound_disrupted = inbound_disrupted + 1
    end 
    setmetatable(self, Flight)
    return self
end     

function Flight:isDelayFeasible(delay)
    return delay <= 1440 and ports[self.port1]:isTimeFeasible(self.time1 + delay) and ports[self.port2]:isTimeFeasible(self.time2 + delay)
end 

function Flight:getDelayCost(delay)
    local function passDelayCoeff(delay)
        if delay > 0 then
            local box = {0, 60, 120, 240, 720, 1440}
            local coeff = {1, 1.5, 2, 3, 5}
            for i=2,#box do   
                if delay > box[i-1] and delay <= box[i] then
                    return coeff[i-1]
                end 
            end 
            error('This flight should be canceled')
        end 
        return 0
    end 
    local cost = 0
    if delay > 0 then
        cost = cost + PENALTY[2] + PENALTY[5] * delay + passDelayCoeff(delay) * self.pass
    end 
end 

function Flight:getCraftSwapCost(craft_id)
    local cost = 0
    local type_type = {{0,1,2,3,5},
        {1,0,1.5,2.5,4},
        {2,1.5,0,2,3.5},
        {3,2.5,2,0,2},
        {5,4,3.5,2,0}}
    if self.id ~= craft_id then
        if self.tp ~= crafts[craft_id].tp then
            cost = cost + PENALTY[4] * type_type[crafts[craft_id].tp][self.tp]
        end 
        cost = cost + PENALTY[6] * math.max(0, self.pass - crafts[craft_id].seat)
    end 
    return cost 
end 
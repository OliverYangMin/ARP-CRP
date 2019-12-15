Column = {}
Column.__index = Column 

function Column:new(label)
    local self = {craft = label.cid, reduced_cost = label.cost} --, delay = delay}
    for i=1,#label do
        self[i] = crafts[label.cid].nodes[label[i]].id
    end 
    setmetatable(self, Column)
    return self
end 

function Column:getCost()
    if not self.cost then
        self.cost = evaluator:getCost(self)
    end 
    return self.cost
end 

function Column:getDelayColumns(time)
    for i=1,#self do
        local flight = flights[self[i]]
        if flight.dis then 
            local delayed_column = self:copy()
            delayed_column.delay[i] = time
            return delayed_column
        end 
    end 
end 

function Column:isInclude(flight_id)
    for i=1,#self do
        if self[i] == flight_id then
            return true
        end 
    end    
    return false
end 

function Column:copy()
    return DeepCopy(self)
end 

--function Column:new(craft_id, delay)
--    local self = {craft = craft_id} --, delay = delay}
--    setmetatable(self, Column)
--    if not self.delay then
--        self.delay = {}
--        for i=1,#self do
--            self.delay[i] = 0
--        end 
--    end 
    
--    self.isEnterDelay = false
--    return self
--end 

--function Column:isInboundSlot(time_slot)
--    local time = 0
--    for i=1,#self
--        local flight = flights[self[i]]
--        local delay = math.max(0, time + self.delay[i] - flight.time1) 
--        if flight.time2 + delay > time_slot and flight.time2 + delay <= time_slot + 10 then
--            return true
--        end 
--        time = flight.time2 + delay + ports[flight.port2][craft.tp]
--    end 
--    return false
--end 

--function Column:isOutboundSlot(time_slot)
--    for i=1,#self
--        if 
--    end 
--    return false
--end 
Column = {}
Column.__index = Column 

function Column:new(seq, craft_id)
    local self = seq
    self.cid = craft_id
    self.cost = evaluator:getCost(self)
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

--function Column:isInSlot(slot)
--    if not self.slot then
--        for i=1,#self do
            
--        end 
--    else
--        return self.slot[]
--    end 
--end 



function Column:copy()
    return DeepCopy(self)
end 
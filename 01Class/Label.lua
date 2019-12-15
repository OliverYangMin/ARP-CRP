
Label = {}
Label.__index = Label

function Label:new(craft_id)
    local self = {cost = 0, delay = 0, cid = craft_id}
    setmetatable(self, Label)
    return self
end     



function Label:isDominate(label)
    if self.cost <= label.cost then
        if #self >= #label then 
            local run_flights_dict = {}
            for i=2,#self-1 do
                run_flights_dict[self[i]] = true
            end 
            for i=2,#label-1 do
                if not run_flights_dict[label[i]] then
                    return false
                end 
            end 
            return true
        end 
    end
    return false
end 

function Label:dominateLabelSet(label_set)
    for i=#label_set,1,-1 do
        if self:isDominate(label_set[i]) then 
            table.remove(label_set, i)
        end 
    end
end 

function Label:to_column()
    local column = Column:new(self)
end 

function Label:copy()
    return DeepCopy(self)
end
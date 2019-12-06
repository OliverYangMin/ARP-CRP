Label = {}
Label.__index = Label

function Label:new(craft_id)
    local self = {cost = 0, delay = 0, cid = craft_id}
    setmetatable(self, Label)
    return self
end     

function Label:extendNode(node1, node2)
    --from the start airport to base airport?
    local flight1, flight2 = flights[node1.id], flights[node2.id]
    local tag, turnaround_time = self:copy(), ports[flight1.port2][self.tp]
    if flight2.id == -1 then  --如果flight2不是终点
        tag.delay = math.max(0, flight1.time2 + label.delay + turnaround_time - flight2.time1)            
        --这个delay是当前航班的delay，之前航班的delay成本已经计算进去了
        if not flight2:isDelayFeasible(tag.delay) then return end 
        -- delay cost & aircraft type,seat change cost
        tag.cost = tag.cost + flight2:getDelayCost(tag.delay) + flight2:getCraftSwapCost(self.cid) +  -- - flight2.dual     
        if flight1.date < flight2.date and flight1.port2 ~= crafts[self.cid].base[flight1.date] then
            tag.cost = tag.cost + 2000
        end 
    end 
    
    tag:append(node2.id)
    
    for _,label in ipairs(node2.labels) do
        if label:isDominate(tag) then 
            return 
        end 
    end 
    
    self:dominateLabelSet(node2.labels)
    table.insert(node2.labels, tag)
end 

function Label:isDominate(label)
    if self.cost <= label2.cost then
        if #self >= #label then 
            local run_flights_dict = {}
            for i=2,#label1-1 do
                run_flights_dict[label1[i]] = true
            end 
            for i=2,#label2-1 do
                if not run_flights_dict[label2[i]] then
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
        if tag:isDominate(label_set[i]) then 
            table.remove(label_set, i)
        end 
    end
end 

function Label:copy()
    return DeepCopy(self)
end

function Label:append(node)
    self[#self+1] = node
end 

--function Label:to_column()
--    local column = Route:new(self.cost)
--    for i=2,#label-1 do 
--        column[#column+1] = self[i]
--    end
--    return column
--end 
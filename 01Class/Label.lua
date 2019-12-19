Label = {}
Label.__index = Label

function Label:new(craft_id, fid)
    local self = {cost = 0, delay = 0, cid = craft_id, fid = fid}
    setmetatable(self, Label)
    return self
end     

function Label:extendNode(node1, node2)
    local flight1 = node1.fid == 0 and {port2 = crafts[self.cid].start, time2 = crafts[self.cid].stime} or flights[node1.fid]
    local flight2 = flights[node2.fid]
    local tag, turnaround_time = Label:new(self.cid, node2.fid), ports[flight1.port2][crafts[self.cid].tp]
    tag.delay = math.max(0, flight1.time2 + self.delay + turnaround_time - flight2.time1)            
    if not flight2:isDelayFeasible(tag.delay) then return end 
    
    tag.cost = self.cost + evaluator:getDelayCost(flight2, tag.delay, crafts[self.cid]) + evaluator:getCraftSwapCost(flight2, crafts[self.cid]) - flight2.dual     
    
    for _,label in ipairs(node2.labels) do
        if label:isDominate(tag) then 
            return 
        end 
    end 
    self:dominateLabelSet(node2.labels)
    tag.pre = self
    table.insert(node2.labels, tag)
end 

function Label:isDominate(label)
    return self.cost - label.cost <= 0.0001 and self.delay <= label.delay 
end 

function Label:dominateLabelSet(label_set)
    for i=#label_set,1,-1 do
        if self:isDominate(label_set[i]) then 
            table.remove(label_set, i)
        end 
    end
end 

function Label:to_column()
    local seq = {self.fid}
    local pre_label = self.pre
    while pre_label do
        seq[#seq+1] = pre_label.fid
        pre_label = pre_label.pre
    end 
    return Column:new(seq, self.cid)
end 

function Label:copy()
    return DeepCopy(self)
end
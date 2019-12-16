Label = {}
Label.__index = Label

function Label:new(craft_id, fid)
    local self = {cost = 0, delay = 0, cid = craft_id, fid = fid}
    setmetatable(self, Label)
    return self
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
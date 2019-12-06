Label = {}
Label.__index = Label

function Label:new()
    local self = {}
    setmetatable(self, Label)
    return self
end     

function Label:isDominate(label)
    if self.cost <= label2.cost then
        if #self == #label then 
            for i=2,#label1-1 do
                if label1[i] ~= label2[i] then 
                    return false
                end 
            end 
            return true
        end 
    end
    return false
end 
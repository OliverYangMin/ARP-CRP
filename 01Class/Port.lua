Port = {}
Port.__index = Port

function Port:new(row)
    local self = {tw = row[7] ~= 0 and {row[7], row[8]}}
    for i=2,6 do
        self[i-1] = row[i] 
    end 
    setmetatable(self, Port)
    return self
end     

function Port:isTimeFeasible(time)
    if self.tw then 
        if time % 1440 >= self.tw[1] then
            return time % 1440 <= self.tw[2]
        else
            return time % 1440 <= self.tw[2] - 1440 
        end 
    end 
    return true
end 
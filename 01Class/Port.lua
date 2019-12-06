Port = {}
Port.__index = Port

function Port:new(row)
    local self = {tw = row[6] ~= 0 and {row[6], row[7]}}
    for j=2,6 do
        table.insert(ports[row[1]], row[j]) 
    end 
    setmetatable(self, Port)
    return self
end     

function Port:isTimeFeasible(time)
    if time % 1440 >= self.tw[1] then
        return time % 1440 <= self.tw[2]
    else
        return time % 1440 <= self.tw[2] - 1440 
    end 
end 
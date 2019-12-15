Flight = {}
Flight.__index = Flight


function Flight:new(id, row)
    local self = {id = id, hbid = row[1], port1 = row[2], port2 = row[3], time1 = row[4] - 1440 * 24, time2 = row[5] - 24 * 1440, pass = row[6], tp = row[7], old = row[8], atp = {row[9], row[10]}}
    setmetatable(self, Flight)
    return self
end  

function Flight:isDelayFeasible(delay)
    return delay <= 1440 and ports[self.port1]:isTimeFeasible(self.time1 + delay) and ports[self.port2]:isTimeFeasible(self.time2 + delay)
end 






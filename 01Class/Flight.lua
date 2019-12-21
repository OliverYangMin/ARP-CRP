Flight = {}
Flight.__index = Flight

function Flight:new(id, row)
    local self = {id = id, hbid = row[1], date = row[2] - 24, port1 = row[3], port2 = row[4], time1 = row[5] - 1440 * 24, time2 = row[6] - 24 * 1440, old = row[7], tp = row[8], pass = row[9], atp = {row[10], row[11]}, water = row[12]}
    setmetatable(self, Flight)
    return self
end  

function Flight:isDelayFeasible(delay)
    return delay <= 1440 and ports[self.port1]:isTimeFeasible(self.time1 + delay) and ports[self.port2]:isTimeFeasible(self.time2 + delay)
end 

function Flight:isOperable(craft)
    return self.atp[craft.tp] > 0 and craft.stime <= self.time1 and self.water <= craft.water --and (craft.fix and (self.time2 > craft.fix[1] and self.time2 <= craft.fix[2]) or true) 
end 
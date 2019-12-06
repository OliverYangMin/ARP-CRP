Flight = {}
Flight.__index = Flight

function Flight:new(id, row)
    local self = {id = id, date = row[3] - 24, port1 = row[4], port2 = row[5], time1 = row[6] - 1440 * 24, time2 = row[7] - 1440 * 24,  old = row[9], tp = row[10], pass = row[11], revenue = row[12], water = row[13], atp = {row[14], row[15], row[16], row[17], row[18]}}
    if self.port1 == 'ZUUU' and self.time1 >= 60 * 13 and self.time1 < 60 * 20 then
        self.dis = true
        self.time1, self.time2 = self.time1 + 60, self.time2 + 60
        outbound_disrupted = outbound_disrupted + 1
    elseif self.port2 == 'ZUUU' and self.time2 >= 60 * 13 and self.time2 < 60 * 20 then
        self.dis = true
        self.time1, self.time2 = self.time1 + 60, self.time2 + 60
        inbound_disrupted = inbound_disrupted + 1
    end 
    setmetatable(self, Flight)
    return self
end     
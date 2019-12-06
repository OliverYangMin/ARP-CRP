Craft = {}
Craft.__index = Craft

function Craft:new()
    local self = {}
    setmetatable(self, Craft)
    return self
end     

function Craft:generateRoute()
    
end 

function Craft:generateNetwork()
    self.fit_flights = {}
    for f,flight in ipairs(flights) do
        if flight.atp[self.tp] then
            self.fit_flights[f] = f
        end 
    end 
    
    
end 
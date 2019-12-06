Craft = {}
Craft.__index = Craft

function Craft:new(row)
    local self = {id = row[1], tp = row[2], seat = row[3], rest = row[4], water = row[7]}
    if row[5] ~= 0 then
        self.fix = {row[5] - 1440 * 24, row[6] - 1440 * 24}
    end 
    setmetatable(self, Craft)
    
    local rotation = {}
    for f,flight in ipairs(flights) do
        if flight.old == c then 
            table.insert(rotation, flight) 
        end 
    end 
    local base = {}
    if #rotation > 0 then 
        self.start = rotation[1].port1
        local i = 1
        for j=1,#rotation do
            if rotation[j].date == i then
                base[i] = rotation[j].port2
            else
                i = i + 1
            end 
        end 
    else
        self.start = 'ZUUU'
        for i=1,7 do
            base[i] = 'ZUUU'
        end 
    end 
    self.base = base
    return self
end     



function Craft:convertLabels2Routes()
    for i,label in ipairs(self.fit_flights[#self.fit_flights].labels) do
        if #label > 2 then 
            local route = {cost = label.cost, craft = self.id}
            for i=2,#label-1 do 
                route[#route+1] = self.fit_flights[label[i]]
            end 
            routes[#routes+1] = route
        end 
    end
    for i=1,#self.fit_flights do self.fit_flights[i].labels = {} end
end 

function Craft:generateRoute()
    for i,node1 in ipairs(self.fit_flights) do
        for _,label in ipairs(node1.labels) do
            for _,node_id in ipairs(node1.adj) do 
                label:extendNode(node1, self.fit_flights[node_id])  
            end 
        end
    end
    self:convertLabels2Routes()
end 

function Craft:filterNetwork()
    self.fit_flights = {}
    for f,flight in ipairs(flights) do
        if flight.atp[self.tp] then
            self.fit_flights[f] = {id = f, labels = {}}
        end 
    end 
end 
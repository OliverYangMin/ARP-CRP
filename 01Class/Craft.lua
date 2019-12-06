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

function Craft:extendLabel(node1, node2)
    --every node has a label set, include a set of labels <totalcost, delay time>, which has no dominance
    --from the start airport to base airport?
    local flight1, flight2 = flights[node1.id], flights[node2.id]
    for _, label in ipairs(node1.labels) do
        local tag = {unpack(label)}
        local turnaround_time = ports[flight1.port2][self.tp]
        if flight2.port2 then  --如果flight2不是终点
            tag.delay = math.max(0, flight1.time2 + label.delay + turnaround_time - flight2.time1)            
            --这个delay是当前航班的delay，之前航班的delay成本已经计算进去了
            if tag.delay > 1440 then goto continue end
            
            ----机场关闭约束
            if ports[flight2.port1].tw and (not time_check_airport(flight2.port1, flight2.time1 + tag.delay)) then goto continue end
            if ports[flight2.port2].tw and (not time_check_airport(flight2.port2, flight2.time2 + tag.delay)) then goto continue end 
                
            --add the delay cost and aircraft change cost
            tag.cost = label.cost + flight_delay_cost(flight2, tag.delay) + craft_swap_cost(flight2, craft) +  -- - flight2.dual     
            if flight1.date < flight2.date and flight1.port2 ~= self.base[flight1.date] then
                tag.cost = tag.cost + 2000
            end 
        else
            tag.cost, tag.delay = label.cost, label.delay
        end 
        tag[#tag+1] = node2.id        
        
        local dominated 
        for _,label in ipairs(node2.labels) do
            if label:isDominate(tag) then 
                dominated = true
                break
            end 
        end 
        
        if not dominated then 
            for i=#node2.labels,1,-1 do
                if tag:isDominate(node2.labels[i]) then 
                    table.remove(node2.labels, i)
                end 
            end
            node2.labels[#node2.labels+1] = tag
        end 
        ::continue::
    end
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
        for j,node2 in ipairs(node.adj) do 
            self:extendLabel(node1, node2) 
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
Craft = {}
Craft.__index = Craft

function Craft:new(row)
    local self = {id = row[1], tp = row[2], seat = row[3], rest = row[4], water = row[7]}
    if row[5] ~= 0 then
        self.fix = {row[5] - 1440 * 24, row[6] - 1440 * 24}
    end 
    setmetatable(self, Craft)
    
    
    local rotation = {}
    local start_dis
    for f,flight in ipairs(flights) do
        if flight.old == c then 
            table.insert(rotation, flight) 
            if flight.dis and not start_dis then start_dis = f end 
        end 
    end 
--    columns[#columns+1] = rotation
--    for t=rotation[start_dis].time1+10,20 * 60,10 do
--        for i=start_dis,#rotation do
            
--        end 
--    end 
    
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

function Craft:isOperable(flight)
    return flight.atp[self.tp] > 0 and flight.water <= self.water and (self.fix and (flight.time2 > self.fix[1] and flight.time2 <= self.fix[2]) or true) 
end 

function Craft:createGraph()
    self.nodes = {}
    for f,flight in ipairs(flights) do
        if self:isOperable(flight) then
            self.nodes[#self.nodes + 1] = {id = f, labels = {}, adj = {}, indegree = 0}
        end 
    end
  
    self.nodes[0] = {id = 0, lables = {{cost = 0, delay = 0}}, adj = {}}
    local edges = self:addEdgesAdjIndegree()
    self:topoSort(edges)
    
    -- may be deleted
    table.insert(self.nodes, {id = -1, lables = {}, adj = {}, indegree = 0})
    for i=1,#self.nodes-1 do
        if flights[self.nodes[i].id].port2 == self.base[DAYS] then
            table.insert(self.nodes[i].adj, #self.nodes)
            self.nodes[#self.nodes].indegree = self.nodes[#self.nodes].indegree + 1
        end 
    end 
end 

function Craft:addEdgesAdjIndegree()
    local edges = {}

    for i,node1 in ipairs(self.nodes) do
        local flight1 = flights[node1.id]
        local turnaround_time = ports[flight1.port2][self.tp]
        edges[i] = {}
        for j,node2 in ipairs(self.nodes) do
            if i ~= j then
                local flight2 = flights[node2.id]
                if flight1.port2 == flight2.port1 and flight1.time1 + turnaround_time <= flight2.time1 then
                    table.insert(edges[i], j)
                    node1.adj[#node1.adj+1] = j
                    node2.indegree = node2.indegree + 1
                end 
            end 
        end
    end 
    
    return edges
end

function Craft:topoSort(edges)
    local minpq = require '03Algorithms.data.minpq'
    local pqueue = minpq.create(function(a, b) return #self.nodes[a].adj - #self.nodes[b].adj end)
    for i=1,#self.nodes do
        if self.nodes[i].indegree == 0 then
            pqueue:enqueue(i)
        end
    end 
    local result = {[0] = 0}
    while not pqueue:isEmpty() do
        local node = pqueue:delMin()
        result[#result+1] = node
        for i=1,#edges[node] do
            self.nodes[edges[node][i]].indegree = self.nodes[edges[node][i]].indegree - 1
            if self.nodes[edges[node][i]].indegree == 0 then
                pqueue:enqueue(edges[node][i])
            end 
        end
    end 
    if #result == #self.nodes then
        self.order = result
    else
        error('This is a cycle of craft ' .. self.id)
    end
end 

function Craft:generateRoute()
    for i=0,#self.order do
        local node = self.nodes[self.order[i]]
        for _,label in ipairs(node.labels) do
            for _,node_id in ipairs(node.adj) do 
                label:extendNode(node, self.nodes[node_id])  
            end 
        end
    end
    --self:convertLabels2Column()
end  

--function Craft:convertLabels2Column()
--    for i,label in ipairs(self.fit_flights[#self.fit_flights].labels) do
--        if #label > 2 then 
--            local route = {cost = label.cost, craft = self.id}
--            for i=2,#label-1 do 
--                route[#route+1] = self.fit_flights[label[i]]
--            end 
--            routes[#routes+1] = route
--        end 
--    end
--    for i=1,#self.fit_flights do self.fit_flights[i].labels = {} end
--end 


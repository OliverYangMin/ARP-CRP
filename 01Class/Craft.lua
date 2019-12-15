Craft = {}
Craft.__index = Craft

function Craft:new(row)
    local self = {id = row[1], tp = row[2], seat = row[3], stime = row[4], start = row[5]}
    setmetatable(self, Craft)
    return self
end     


function Craft:createGraph()
    self.nodes = {}
    for f,flight in ipairs(flights) do
        if self:isOperable(flight) then
            self.nodes[#self.nodes + 1] = {fid = f, labels = {}, adj = {}, indegree = 0}
            if flight.port1 == self.start then
                local label = Label:new(self.id)
                label[1] = f
                table.insert(self.nodes[#self.nodes].labels, label)
            end 
        end 
    end
    self:topoSort(self:addEdgesAdjIndegree())
end 


function Craft:addEdgesAdjIndegree()
    local edges = {}
    for i,node1 in ipairs(self.nodes) do
        local flight1 = flights[node1.fid]
        local turnaround_time = ports[flight1.port2][self.tp]
        edges[i] = {}
        for j,node2 in ipairs(self.nodes) do
            if i ~= j then
                local flight2 = flights[node2.fid]
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



function Craft:isOperable(flight)
    return flight.atp[self.tp] > 0 and self.stime <= flight.time1--and flight.water <= self.water and (self.fix and (flight.time2 > self.fix[1] and flight.time2 <= self.fix[2]) or true) 
end 

function Craft:topoSort(edges)
    local minpq = require '03Algorithms.data.minpq'
    local pqueue = minpq.create(function(a, b) return #self.nodes[a].adj - #self.nodes[b].adj end)
    for i=1,#self.nodes do
        if self.nodes[i].indegree == 0 then
            pqueue:enqueue(i)
        end
    end 
    local result = {}
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
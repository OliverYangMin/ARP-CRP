function init()
    flights, crafts, ports = getData()
    for c,craft in pairs(crafts) do
        craft:createGraph()
    end
        
    evaluator = Evaluator:new()
    initColumns()
end 

function clearLabels()
    for c,craft in pairs(crafts) do
        craft:clearLabels()
    end
end 

function initColumns()
    columns = {}
    for c,craft in pairs(crafts) do
        for i=1,#flights do
            if flights[i].port1 == craft.start then
                columns[#columns+1] = Column:new({i, 0}, c)
            end 
        end
--        if not craft.dis then
--            columns[#columns+1] = getRotation(craft)
--        end 
    end 
end 

function DeepCopy(object)      
    local SearchTable = {}  
    local function Func(object)  
        if type(object) ~= "table" then  
            return object         
        end  
        local NewTable = {}  
        SearchTable[object] = NewTable  
        for k, v in pairs(object) do  
            NewTable[Func(k)] = Func(v)  
        end     
        return setmetatable(NewTable, getmetatable(object))      
    end    
    return Func(object)  
end 

local function read_csv(filename, ihead)
	local inputdata = io.input(filename)
	local matrix = {}
	ihead = ihead or 0
	for line in inputdata:lines() do
		if ihead > 0 then
			matrix[ihead] = {}
			for element in string.gmatch(line, "[0-9%.A-Z]+") do
                matrix[ihead][#matrix[ihead]+1] = tonumber(string.match(element,'[0-9%.]+')) or element
			end
		end 
		ihead = ihead + 1
	end
    io.close()
	return matrix
end

function getData()
    local flights = {}
    local data = read_csv('00Data/flights_info.csv')
    for i=1,#data do
        flights[#flights+1] = Flight:new(i, data[i])
    end 
    
    local ports = {}
    data = read_csv('00Data/airports_info.csv')
    for i=1,#data do ports[data[i][1]] = Port:new(data[i]) end
    
    local crafts = {}
    data = read_csv('00Data/aircrafts_info.csv')
    for i=1,#data do crafts[data[i][1]] = Craft:new(data[i]) end 
    
    local function getRotation(c)
        local rotation = {}
        for f,flight in pairs(flights) do
            if flight.old == c then 
                table.insert(rotation, flight) 
            end 
        end 
        table.sort(rotation, function(a,b) return a.time1 < b.time1 end)
        return rotation
    end 
    
    for c,craft in pairs(crafts) do
        local rotation = getRotation(c)
        if #rotation > 0 then
            
            
            craft.base = rotation[#rotation].port2
            craft.start = rotation[1].port1
        else
            crafts[c] = nil
        end 
    end 
    
    for f,flight in pairs(flights) do
        if flight.port1 == 'ZUUU' then
            if flight.time1 >= 360 and flight.time1 < 480 then
                flight.time1, flight.time2 = flight.time1 + 120, flight.time2 + 120
                flight.impacted = true
            end 
        elseif flight.port2 == 'ZUUU' then
            if flight.time2 >= 360 and flight.time2 < 600 then
                flight.time1, flight.time2 = flight.time1 + 120, flight.time2 + 120
                flight.impacted = true
            end 
        end 
    end 
    return flights, crafts, ports
end 
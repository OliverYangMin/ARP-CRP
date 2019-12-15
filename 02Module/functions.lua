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
    flights = {}
    local data = read_csv('00Data/flights_info.csv')
    for i=1,#data do
        flights[#flights+1] = Flight:new(i, data[i])
    end 

    ports = {}
    data = read_csv('00Data/airports_info.csv')
    for i=1,#data do ports[data[i][1]] = Port:new(data[i]) end
    
    crafts = {}
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
            if flight.time1 >= 480 and flight.time1 <= 600 then
                flight.time1, flight.time2 = flight.time1 + 120, flight.time2 + 120
                flight.impacted = true
            end 
        elseif flight.port2 == 'ZUUU' then
            if flight.time2 >= 480 and flight.time2 <= 600 then
                flight.time1, flight.time2 = flight.time1 + 120, flight.time2 + 120
                flight.impacted = true
            end 
        end 
    end 


end 

--function getData()
--    flights = {}
--    local data = read_csv('00Data/flights_info.csv')
--    for i=1,#data do
--        flights[data[i][1]] = Flight:new(data[i])
--    end 

--    ports = {}
--    data = read_csv('00Data/airports_info.csv')
--    for i=1,#data do ports[data[i][1]] = Port:new(data[i]) end
    
--    crafts = {}
--    data = read_csv('00Data/aircrafts_info.csv')
--    for i=1,#data do crafts[data[i][1]] = Craft:new(data[i]) end 
    
--    local function getRotation(c)
--        local rotation = {}
--        for f,flight in pairs(flights) do
--            if flight.date >= 0 and flight.old == c then 
--                table.insert(rotation, flight) 
--            end 
--        end 
--        return rotation
--    end 
    
--    for c,craft in pairs(crafts) do
--        local rotation = getRotation(c)
--        if #rotation > 0 then
--            craft.base = rotation[#rotation].port2
--            craft.start = rotation[1].port1
--        else
--            craft[c] = nil
--        end 
--    end 
--end 





--    local start = 13 * 60 
--    for c,craft in pairs(crafts) do
--        local rotation = getRotation(c)   
--        local base = {}
--        local days = {}
--        for i=0,7 do
--            days[i] = {}
--        end 
        
--        for i=1,#rotation do
--            if rotation[i].date > 0 then
--                table.insert(days[rotation[i].date], i)
--            else
--                table.insert(days[0], i)
--            end 
--            if i < #rotation then
--                if rotation[i].hbh == rotation[i+1]].hbh then
--                    rotation[i].double = rotation[j+1].id
--                end 
--            end 
--        end 
        
--        for i=1,7 do
--            if #days[i] > 0 then
--                craft.start = rotation[days[i][1]].port1
--                break
--            end 
--        end 
        
--        if not craft.start then
--            if #days[0] > 0 then
--                craft.start = rotation[days[0][#days[0]]].port2
--            else
--                craft.start = 'ZUUU'
--                print('craft ', c, 'have no flights?')
--            end 
--        end 
        
--        for i=1,7 do
--            if #days[i] > 0 then
--                base[i] = rotation[days[i][#days[i]]].port2
--            else
--                if i == 1 then 
--                    if #days[0] > 0 then
--                        base[i] = rotation[days[0][#days[0]]].port2
--                    else
--                        base[i] = 'ZUUU'
--                    end 
--                else
--                    base[i] = base[i-1]
--                end 
--            end 
--        end 
        
--        if #days[1] == 0 then
--            craft.stime = start
--        else
--            for i,rid in ipairs(days[1]) do
--                if rotation[rid].time1 < start and rotation[rid].time2 + ports[rotation[rid].port2][craft.tp] > start then
--                    craft.stime = rotation[rid].time2 + ports[rotation[rid].port2][craft.tp]
--                    craft.start = rotation[rid].port2
--                    craft.inbound_slot_delay = rotation[rid].port2 == 'ZUUU' and craft.stime or 0
--                    craft.cut = math.floor(ports[rotation[rid].port2][craft.tp]/3)
--                end 
--                if rotation[rid].time1 >= start then
--                    craft.stime = start
--                    craft.start = rotation[rid].port1
----                    break
----                end 
----            end 
----        end   
----        craft.base = base
----    end 
----end 

----function getData()
----    flights = {}
----    local data = read_csv('00Data/flights_info.csv')
----    for i=1,#data do
------        if data[i][6] >= 24 *1440 + 13 * 60 then -- data[i][3] < 25 + DAYS  then
------            flights[#flights+1] = Flight:new(i, data[i])  -- could be changed flights
------        end 
        
----        if data[i][2] > 24 then --and data[i][2] < 25 + DAYS  then
------            local flight = Flight:new(i, data[i])
------            if flight.time1 >= 13 * 60 then
------                flights[#flights+1] = flight 
------            elseif flight.time2 
------            end 
----            flights[#flights+1] = Flight:new(i, data[i])
----        end 
----    end 

     
--    ports = {}
--    data = read_csv('00Data/airports_info.csv')
--    for i=1,#data do ports[data[i][1]] = Port:new(data[i]) end
    
--    crafts = {}
--    data = read_csv('00Data/aircrafts_info.csv')
--    for i=1,#data do crafts[data[i][1]] = Craft:new(data[i]) end 
   

--    mcrafts = {}
--    mflights = {}
--    for c,craft in pairs(crafts) do
--        local rotation = {}
--        for f,flight in ipairs(flights) do
--            if flight.old == c then
--                rotation[#rotation+1] = f
--                if flight.dis and not mcrafts[c] then
--                    mcrafts[c] = craft
--                end 
--            end 
--        end
        
--        for j=1,#rotation-1 do
--            if flights[rotation[j]].hbh == flights[rotation[j+1]].hbh then
--                flights[rotation[j]].double = rotation[j+1]
--            end 
--        end 
        
--        if mcrafts[c] then
--            for i=1,#rotation do
--                mflights[#mflights+1] = flights[rotation[i]]
--            end 
--        end     
--    end 
--    flights = mflights
--    crafts = mcrafts
--end 
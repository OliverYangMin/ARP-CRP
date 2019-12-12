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
        flights[data[i][1]] = Flight:new(data[i])
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
        if flight.date >= 0 and flight.old == c then 
            table.insert(rotation, flight) 
        end 
    end 
    return rotation
end 

    local start = 13 * 60 
    for c,craft in pairs(crafts) do
        local rotation = getRotation(c)   
        local base = {}
        local days = {}
        for i=0,7 do
            days[i] = {}
        end 
        
        for i=1,#rotation do
            if rotation[i].date > 0 then
                table.insert(days[rotation[i].date], i)
            else
                table.insert(days[0], i)
            end 
            if i < #rotation then
                if rotation[i].hbh == rotation[i+1]].hbh then
                    rotation[i].double = rotation[j+1].id
                end 
            end 
        end 
        
        for i=1,7 do
            if #days[i] > 0 then
                craft.start = rotation[days[i][1]].port1
                break
            end 
        end 
        
        if not craft.start then
            if #days[0] > 0 then
                craft.start = rotation[days[0][#days[0]]].port2
            else
                craft.start = 'ZUUU'
                print('craft ', c, 'have no flights?')
            end 
        end 
        
        for i=1,7 do
            if #days[i] > 0 then
                base[i] = rotation[days[i][#days[i]]].port2
            else
                if i == 1 then 
                    if #days[0] > 0 then
                        base[i] = rotation[days[0][#days[0]]].port2
                    else
                        base[i] = 'ZUUU'
                    end 
                else
                    base[i] = base[i-1]
                end 
            end 
        end 
        
        if #days[1] == 0 then
            craft.stime = start
        else
            for i,rid in ipairs(days[1]) do
                if rotation[rid].time1 < start and rotation[rid].time2 + ports[rotation[rid].port2][craft.tp] > start then
                    craft.stime = rotation[rid].time2 + ports[rotation[rid].port2][craft.tp]
                    craft.start = rotation[rid].port2
                    craft.inbound_slot_delay = rotation[rid].port2 == 'ZUUU' and craft.stime or 0
                    craft.cut = math.floor(ports[rotation[rid].port2][craft.tp]/3)
                end 
                if rotation[rid].time1 >= start then
                    craft.stime = start
                    craft.start = rotation[rid].port1
                    break
                end 
            end 
        end   
        craft.base = base
    end 
end 

--function getData()
--    flights = {}
--    local data = read_csv('00Data/flights_info.csv')
--    for i=1,#data do
----        if data[i][6] >= 24 *1440 + 13 * 60 then -- data[i][3] < 25 + DAYS  then
----            flights[#flights+1] = Flight:new(i, data[i])  -- could be changed flights
----        end 
        
--        if data[i][2] > 24 then --and data[i][2] < 25 + DAYS  then
----            local flight = Flight:new(i, data[i])
----            if flight.time1 >= 13 * 60 then
----                flights[#flights+1] = flight 
----            elseif flight.time2 
----            end 
--            flights[#flights+1] = Flight:new(i, data[i])
--        end 
--    end 

     
    ports = {}
    data = read_csv('00Data/airports_info.csv')
    for i=1,#data do ports[data[i][1]] = Port:new(data[i]) end
    
    crafts = {}
    data = read_csv('00Data/aircrafts_info.csv')
    for i=1,#data do crafts[data[i][1]] = Craft:new(data[i]) end 
   

    mcrafts = {}
    mflights = {}
    for c,craft in pairs(crafts) do
        local rotation = {}
        for f,flight in ipairs(flights) do
            if flight.old == c then
                rotation[#rotation+1] = f
                if flight.dis and not mcrafts[c] then
                    mcrafts[c] = craft
                end 
            end 
        end
        
        for j=1,#rotation-1 do
            if flights[rotation[j]].hbh == flights[rotation[j+1]].hbh then
                flights[rotation[j]].double = rotation[j+1]
            end 
        end 
        
        if mcrafts[c] then
            for i=1,#rotation do
                mflights[#mflights+1] = flights[rotation[i]]
            end 
        end     
    end 
    flights = mflights
    crafts = mcrafts
end 



function calculateCost()
    local cost = 0
    for f,flight in ipairs(flights) do
        ---是否取消航班
        if not flight.new then
            cost = cost + P[1]
            cost = cost + P[6] * flight.pass
        else
            ---航班是否延误
            if flight.time > flight.time1 then
                cost = cost + P[2]
                cost = cost + P[5] * (flight.time - flight.time1)
                cost = cost + passenger_delay_cost(flight.time - flight.time1, flight.pass, P[7])
            end 
            
            ---是否更换飞机
            if flight.new ~= flight.old then
                ---是否更换机型
                if crafts[flight.new].atp ~= flight.atp then
                    cost = cost + P[4] * d[crafts[flight.new].atp][flight.atp]
                else
                    
                end
            end 
            
            ---是否缩减过站时间
            if flight.gtime < ports[flight.port2][crafts[flight.new].atp] then
                cost = cost + P[9]
            end 
        end 
    end 
    
    for c,craft in ipairs(crafts) do
        for i=1,DAYS do
            if craft.base[i] ~= craft.new_base[i] then
                cost = cost + P[3]
            end 
        end
    end 
end 
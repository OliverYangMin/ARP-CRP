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

function getData()
    flights = {}
    inbound_disrupted, outbound_disrupted = 0, 0
    local data = read_csv('00Data/flights_info.csv')
    for i=1,#data do
        if data[i][3] > 24 and data[i][3] < 27 then
            flights[#flights+1] = Flight:new(i, data[i])
        end 
    end 
    
    crafts = {}
    data = read_csv('00Data/aircrafts_info.csv')
    for i=1,#data do crafts[data[i][1]] = Craft:new(data[i]) end 

    ports = {}
    data = read_csv('00Data/airports_info.csv')
    for i=1,#data do
        ports[data[i][1]] = Port:new(data[i]) 
    end
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
        for i=1,7 do
            if craft.base[i] ~= craft.new_base[i] then
                cost = cost + P[3]
            end 
        end
    end 
end 
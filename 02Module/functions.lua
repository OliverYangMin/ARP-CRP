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
        if data[i][3] > 24 and data[i][3] < 27 then
            flights[#flights+1] = {id=i, date = data[i][3] - 24, port1 = data[i][4], port2 = data[i][5], time1 = data[i][6] - 1440 * 24, time2 = data[i][7] - 1440 * 24,  old = data[i][9], tp = data[i][10], pass = data[i][11], revenue = data[i][12], water = data[i][13], atp = {data[i][14], data[i][15], data[i][16], data[i][17], data[i][18]}}
        end 
    end 

    crafts = {}
    data = read_csv('00Data/aircrafts_info.csv')
    for i=1,#data do
        crafts[data[i][1]] = {id = data[i][1], tp = data[i][2], seat = data[i][3], rest = data[i][4], water = data[i][7]}
        if data[i][5] ~= 0 then
            crafts.fix = {data[i][5], data[i][6]}
        end 
        -- base = {}, start, 
    end 
    crafts[54] = {id = 54, tp = 4, seat = 301, rest = 2, water = 1}

    ports = {}
    data = read_csv('00Data/airports_info.csv')
    for i=1,#data do
        ports[data[i][1]] = {tw = data[i][6] ~= 0 and {data[i][6], data[i][7]}}
        for j=2,6 do
            table.insert(ports[data[i][1]], data[i][j]) 
        end 
    end 
    
    rotations = {}
    for c,craft in ipairs(crafts) do
        local rotation = {}
        for f,flight in ipairs(flights) do
            if flight.old == c then
                table.insert(rotation,flight)
            end 
        end 
        local base = {}
        if #rotation > 0 then 
            craft.start = rotation[1].port1
            local i = 1
            for j=1,#rotation do
                if rotation[j].date == i then
                    base[i] = rotation[j].port2
                else
                    i = i + 1
                end 
            end 
        else
            craft.start = 'ZUUU'
            for i=1,7 do
                base[i] = 'ZUUU'
            end 
        end 
        craft.base = base
        rotations[c] = rotation
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
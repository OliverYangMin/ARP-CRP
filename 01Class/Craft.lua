
--function Craft:convertLabels2Routes()
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


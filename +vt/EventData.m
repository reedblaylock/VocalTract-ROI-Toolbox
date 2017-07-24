classdef (ConstructOnLoad) EventData < event.EventData
	properties
		data
	end
	
	methods
		function this = EventData(newData)
			this.data = newData;
		end
	end
	
end


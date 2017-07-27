classdef Increment < vt.Action
	events
		INCREMENT
	end
	
	methods
		function this = Increment(data)
			p = inputParser;
			p.addRequired('data', @isnumeric);
			parse(p, data);
			
			this@vt.Action(data);
		end
	end
end


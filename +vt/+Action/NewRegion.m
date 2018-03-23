classdef NewRegion < vt.Action
	events
		NEW_REGION
	end
	
	properties
		region
	end
	
	methods (Static, Access = private)
		function out = getOrIncrementCount(increment)
			persistent id;
			if isempty(id)
				id = 0;
			end
			if nargin
				id = id + increment;
			end
			out = id;
		end
	end
	
	methods
		function [] = prepare(this)
			config = vt.Config();
			this.region = config.region;
			
			% Increment the counter in the constructor
			this.region.id = vt.Action.NewRegion.getOrIncrementCount(1);
			this.region.name = ['Region' num2str(this.region.id)];
		end
	end
end


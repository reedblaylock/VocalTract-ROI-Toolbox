classdef NewRegion < vt.Action
	events
		NEW_REGION
	end
	
	properties
		region
% 		id = 0
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
			this.region.color = this.getNextColor();
		end
		
		function color = getNextColor(this)
			% Adopted from:
			% https://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
			% Doesn't give as much color dispersion as you'd like
			golden_ratio_conjugate = 0.618033988749895;
% 			h = rand;
% 			h = h + golden_ratio_conjugate;
			h = golden_ratio_conjugate * vt.Action.NewRegion.getOrIncrementCount();
			h = mod(h, 1);
			color = hsv2rgb(h, 0.8, 0.95);
		end
		
		function [] = delete(this)
			delete@vt.Action.NewRegion(this);
			clear vt.Action.NewRegion;
		end
	end
end


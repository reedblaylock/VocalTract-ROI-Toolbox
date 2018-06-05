classdef NewRegion < vt.Action
	events
		NEW_REGION
	end
	
	properties
		region
		id = 0
	end
	
	% TODO: When you load states from a previous session, this will overwrite
	% IDs.
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
% 		function out = getOrIncrementCount(this, increment)
% 			p = inputParser;
% 			addOptional(p, 'increment', 0, @isnumeric);
% 			parse(p, increment);
% 			
% 			if increment
% 				this.id = this.id + p.Results.increment;
% 			end
% 			
% 			out = this.id;
% 		end
		
		function [] = prepare(this)
			config = vt.Config();
			this.region = config.region;
			
			% Increment the counter in the constructor
			this.region.id = vt.Action.NewRegion.getOrIncrementCount(1);
% 			this.region.id = this.getOrIncrementCount(1);
			this.region.name = ['Region' num2str(this.region.id)];
		end
		
		function [] = delete(this)
			delete@vt.Action.NewRegion(this);
			clear vt.Action.NewRegion;
		end
	end
end


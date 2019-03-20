classdef Help < redux.Action
	events
		HELP
	end
	
	methods
		function [] = prepare(this)
			% do nothing
		end
		
		function [] = help(this)
			disp('Showing Help...');
		end
	end
end


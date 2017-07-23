classdef InputParser < inputParser
	properties
	end
	
	methods
		function [] = addAction(this)
			this.addRequiredAction();
		end
		
		function [] = addRequiredAction(this)
			this.addRequired('action', @ischar);
		end
		
		function [] = addOptionalAction(this)
			this.addOptional('action', '', @ischar);
		end
		
		function [] = addParent(this)
			fcn = @(parent) isa(parent, 'vt.Component');
			this.addRequired('parent', fcn);
		end
	end
	
end


classdef InputParser < inputParser
	methods
		function [] = addParent(this)
			fcn = @(parent) isa(parent, 'vt.Component');
			this.addRequired('parent', fcn);
		end
	end
	
end


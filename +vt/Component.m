classdef (Abstract) Component < vt.Root
	
	properties
		handle
	end
	
	methods		
		function [] = setParameters(this, varargin)
			p = inputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component'));
			parse(p, this, varargin{:});
			
			params = fieldnames(p.Unmatched);

			for i = 1:numel(params)
				set(this.handle, params{i}, p.Unmatched.(params{i}));
			end
		end
	end
	
end


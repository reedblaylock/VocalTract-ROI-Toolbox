classdef ChangeRegionParameter < redux.Action
	events
		CHANGE_REGION_PARAMETER
	end
	
	properties
		region
		parameter
		value
	end
	
	methods
		function [] = prepare(this, region, parameter, value, varargin)
			p = inputParser;
			p.StructExpand = false;
			addRequired(p, 'region');
			addRequired(p, 'parameter');
% 			addOptional(p, 'value', []);
			addRequired(p, 'value');
			addOptional(p, 'video', []);
			parse(p, region, parameter, value, varargin{:});
			
			region = p.Results.region;
			parameter = p.Results.parameter;
			value = p.Results.value;
			video = p.Results.video;
			
			switch(parameter)
				% Parameter/value sets
				case {'origin', 'shape', 'type', 'radius', 'width', 'height', 'minPixels'}
					region.(parameter) = value;
					
					if ~isempty(region.origin)
						region.mask = vt.Action.getMask(region, video);
						region.timeseries = vt.Action.findTimeseries(region, video);
					end
				case {'color', 'name', 'showOrigin', 'showOutline', 'timeseriesDimension'}
					region.(parameter) = value;
				otherwise
					% TODO: throw error
			end
			
			this.region = region;
			this.parameter = parameter;
			this.value = value;
		end
	end
end
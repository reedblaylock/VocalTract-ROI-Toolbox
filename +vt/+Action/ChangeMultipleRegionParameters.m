classdef ChangeMultipleRegionParameters < redux.Action
	events
		CHANGE_MULTIPLE_REGION_PARAMETERS
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
            
            if numel(parameter) ~= numel(value)
                error('Error in ChangeMultipleRegionParameters: unmatched parameters and values');
            end
            
            new_ts = false;
            for i = 1:numel(parameter)
                param = parameter{i};
                val = value{i};
                region.(param) = val;
                switch(param)
                    % Parameter/value sets
                    case {'origin', 'shape', 'type', 'radius', 'width', 'height', 'search_radius', 'tau', 'pixel_minimum'}
                        new_ts = true;
                    otherwise
                        % TODO: throw error
                end
            end
            
            if new_ts
                if ~isempty(region.origin)
                    region.mask = vt.Action.getMask(region, video);
                    region.timeseries = vt.Action.findTimeseries(region, video);
                end
            end
			
			this.region = region;
			this.parameter = parameter;
			this.value = value;
		end
	end
end
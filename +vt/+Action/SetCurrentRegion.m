classdef SetCurrentRegion < vt.Action
	events
		SET_CURRENT_REGION
	end
	
	properties
		id = []
	end
	
	methods
		function [] = prepare(this, coordinates, regions)
			% TODO: For overlapping regions, pick the region based on some
			% algorithm
			coordinates = fliplr(coordinates);
			for iRegion = 1:numel(regions)
				mask = regions(iRegion).mask;
				if(mask(coordinates(1), coordinates(2)))
					this.id = regions(iRegion).id;
				end
			end
		end
	end
end


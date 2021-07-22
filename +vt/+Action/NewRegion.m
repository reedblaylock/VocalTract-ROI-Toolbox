classdef NewRegion < redux.Action
	events
		NEW_REGION
	end
	
	properties
		region
% 		id = 0
	end
	
% 	methods (Static, Access = private)
% 		function out = getOrIncrementCount(increment)
% 			persistent id;
% 			if isempty(id)
% 				id = 0;
% 			end
% 			if nargin
% 				id = id + increment;
% 			end
% 			out = id;
% 		end
% 	end
	
	methods		
		function [] = prepare(this, regions)
			config = vt.Config();
			this.region = config.region;
            
            if numel(regions) < 1
                newID = 1;
            else
                % Get the ID of every region
                region_IDs = zeros(1, numel(regions));
                for iRegion = 1:numel(regions)
                    region_IDs(iRegion) = regions{iRegion}.id;
                end
                newID = max(region_IDs) + 1;
            end
			
			% Increment the counter in the constructor
            this.region.id = newID;
            this.region.name = ['Region ' num2str(newID)];
% 			this.region.id = vt.Action.NewRegion.getOrIncrementCount(1);
% 			this.region.name = ['Region' num2str(this.region.id)];
			this.region.color = this.getNextColor(newID);
		end
		
		function color = getNextColor(~, newID)
			% Color scheme: Tartan (author unknown)
			% Source: http://terminal.sexy/#Kysr3t7eLjQ2zAAATpoGxKAANGWkdVB7Bpia09fPVVdT7ykpiuI0_OlPcp_PrX-oNOLi7u7s
			
			colors = [
				'#EF2929'; % red
				'#8AE234'; % green
				'#FCE94F'; % yellow
				'#729FCF'; % blue
				'#AD7FA8'; % purple
				'#34E2E2'  % cyan
			];
			
			colors = hex2rgb(colors);
			
			% Cycle through the colors every six regions
			i = mod(newID - 1, 6) + 1;
			color = colors(i, :);
		end
		
% 		function color = getNextColor(this)
% 			% Adopted from:
% 			% https://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
% 			% Doesn't give as much color dispersion as you'd like
% 			golden_ratio_conjugate = 0.618033988749895;
% % 			h = rand;
% % 			h = h + golden_ratio_conjugate;
% 			h = golden_ratio_conjugate * vt.Action.NewRegion.getOrIncrementCount();
% 			h = mod(h, 1);
% 			color = hsv2rgb(h, 0.8, 0.95);
% 		end
		
% 		function [] = delete(this)
% 			delete@vt.Action.NewRegion(this);
% 			clear vt.Action.NewRegion;
% 		end
	end
end


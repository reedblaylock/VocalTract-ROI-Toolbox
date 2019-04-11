classdef TimeseriesArray < redux.Component.Layout.VBox & redux.State.Listener
	properties
		gui
		timeseriesLabels
		containerLabels
% 		styles
	end
	
	methods
		function this = TimeseriesArray(parent, styles)
			this@redux.Component.Layout.VBox( ...
				parent, ...
				'Padding', styles.Padding, ...
				'Spacing', styles.Spacing ...
			);
			
			this.timeseriesLabels = {};
			this.containerLabels = {};
% 			this.styles = styles;
		end
		
		function gui = render(this, gui)
			this.gui = gui;
		end
		
		function label = generateLabel(this, idNo)
			label = ['Timeseries' num2str(idNo)];
		end
		
		function [] = registerLabel(this, label)
			this.timeseriesLabels{end+1} = label;
		end
		
		function [] = unregisterLabel(this, label)
			for iLabel = 1:numel(this.timeseriesLabels)
				if strcmp(this.timeseriesLabels{iLabel}, label)
					this.timeseriesLabels(iLabel) = [];
					break;
				end
			end
		end
		
		function containerLabel = generateContainerLabel(this, label)
			containerLabel = [label 'Container'];
		end
		
		function [] = registerContainerLabel(this, containerLabel)
			this.containerLabels{end+1} = containerLabel;
		end
		
		function [] = unregisterContainerLabel(this, containerLabel)
			for iLabel = 1:numel(this.containerLabels)
				if strcmp(this.containerLabels{iLabel}, containerLabel)
					this.containerLabels(iLabel) = [];
					break;
				end
			end
		end
		
		function [] = deleteAllTimeseries(this, ~)
			labels = this.timeseriesLabels;
			containerLabels = this.containerLabels;
			
			for iDeletion = 1:numel(labels)
				label = labels{iDeletion};
				containerLabel = containerLabels{iDeletion};
				
				this.unregisterLabel(label);
				this.unregisterContainerLabel(containerLabel);
% 				this.gui.guiDelete(containerLabel);
% 				this.gui.guiDelete(label);
			end
			
			delete(this.handle.Contents(:));
		end
		
		function [] = redrawAllTimeseries(this, state)
			if isempty(state.regions) || ~numel(state.regions)
				% There are no regions to draw
				return;
			end
			
			for iRegion = 1:numel(state.regions)
				region = state.regions{iRegion};
				if ~isempty(region.timeseries)
					label = this.generateLabel(region.id);
					containerLabel = this.generateContainerLabel(label);
					
					this.drawTimeseries(region, state.currentFrameNo, label, containerLabel);
					
					this.registerLabel(label);
					this.registerContainerLabel(containerLabel);
				end
			end
		end
		
		function [] = drawTimeseries(this, region, currentFrameNo, label, containerLabel)
			% Create a container for the Timeseries Component to go on
			this.gui.(containerLabel) = redux.Component.Container( ...
				this.gui.TimeseriesArray, ...
				'Tag', label ...
			);
		
			if strcmpi(region.type, 'centroid')
				switch (region.timeseriesDimension)
					case 'x'
						timeseries = region.timeseries(:,1);
					case 'y'
						timeseries = region.timeseries(:,2);
						% flip
						timeseries = max(timeseries) - timeseries + min(timeseries);
% 					case 'tangential_velocity'
% 				% Get distance between consecutive points
% 				% https://www.mathworks.com/matlabcentral/answers/323030-how-to-find-distance-between-consecutive-points
% 				data = sqrt( sum( abs( diff( p.Results.data ) ).^2, 2 ) );
% 				% TODO: hack to get the right number of frames
% 				data(end+1) = data(end);
					otherwise
						error('Not a valid timeseriesDimension');
				end
			else
				timeseries = region.timeseries;
			end

			this.gui.(label) = vt.Component.Timeseries( ...
				this.gui.(containerLabel), ...
				timeseries, ...
				region.color, ...
				currentFrameNo, ...
				'Title', region.name, ...
				'Tag', label ...
			);
		end
		
		function [] = refreshAllTimeseries(this, state)
			this.deleteAllTimeseries(state);
			this.redrawAllTimeseries(state);
		end
		
		%%% State.Listener functions
		function [] = onRegionsChange(this, state)
			% TODO: order display by (xcoordinate + ycoordinate) increasing
			
			this.refreshAllTimeseries(state);
		end
		
		function [] = onVideoChange(this, state)
			this.refreshAllTimeseries(state);
		end
		
		function [] = onCurrentFrameNoChange(this, state)
			for iTimeseriesLabel = 1:numel(this.timeseriesLabels)
				label = this.timeseriesLabels{iTimeseriesLabel};
				this.gui.(label).updateFrameNoLine(state.currentFrameNo);
			end
		end
	end
	
end


classdef Region
    
    properties
        id
        name
        origin
        type
        shape
        radius
        height
        width
        minPixels % pixel_Minimum ?
        tau
        searchRadius
        mask
        timeseriesDimension
        color
        showOrigin
        showOutline
        
        timeseries
        smooth_timeseries
        display_timeseries
    end
    
    methods
        function obj = Region(fname_regions, video)
            if nargin ~= 0
                temp_regions = load(fname_regions);
                regions = temp_regions.vt_regions.regions;
                n = numel(regions);
                obj(n,1) = obj;

                for iRegion = 1:numel(regions)
                    obj(iRegion).id = regions{iRegion}.id;
                    obj(iRegion).name = string(regions{iRegion}.name);
                    obj(iRegion).origin = regions{iRegion}.origin;
                    obj(iRegion).type = regions{iRegion}.type;
                    obj(iRegion).shape = regions{iRegion}.shape;
                    obj(iRegion).radius = regions{iRegion}.radius;
                    obj(iRegion).height = regions{iRegion}.height;
                    obj(iRegion).width = regions{iRegion}.width;
                    
                    if ismember(fieldnames(regions{iRegion}), 'minPixels')
                        obj(iRegion).minPixels = regions{iRegion}.minPixels;
                    elseif ismember(fieldnames(regions{iRegion}), 'pixel_minimum')
                        obj(iRegion).minPixels = regions{iRegion}.pixel_minimum;
                    end
                    
                    obj(iRegion).tau = regions{iRegion}.tau;
                    
                    if ismember(fieldnames(regions{iRegion}), 'searchRadius')
                        obj(iRegion).minPixels = regions{iRegion}.searchRadius;
                    elseif ismember(fieldnames(regions{iRegion}), 'search_radius')
                        obj(iRegion).minPixels = regions{iRegion}.search_radius;
                    end
                    
                    obj(iRegion).mask = regions{iRegion}.mask;
                    obj(iRegion).timeseriesDimension = regions{iRegion}.timeseriesDimension;
                    obj(iRegion).color = regions{iRegion}.color;
                    obj(iRegion).showOrigin = regions{iRegion}.showOrigin;
                    obj(iRegion).showOutline = regions{iRegion}.showOutline;

                    % Get the basic time series
                    obj(iRegion).timeseries = vt.Action.findTimeseries(regions{iRegion}, video);

                    % Get the smooth time series
                    obj(iRegion).smooth_timeseries = obj.findSmoothTimeseries(obj(iRegion).timeseries);

                    % Get the display time series
                    obj(iRegion).display_timeseries = obj.findDisplayTimeseries(obj(iRegion).timeseries);
                end
            end
        end
        
        function smooth_timeseries = findSmoothTimeseries(obj, ts)
            % LWREGRESS FOR SINGING DATA, NOT FOR BEATBOXING DATA
    %         regions{iRegion}.smooth_timeseries = lwregress((1:length(regions{iRegion}.timeseries))', regions{iRegion}.timeseries, linspace(1, length(regions{iRegion}.timeseries), 4*length(regions{iRegion}.timeseries))', 0.9, 0);
    %         regions{iRegion}.smooth_timeseries = smooth(rescale(regions{iRegion}.timeseries, 1, 5));
            smooth_timeseries = [];
            for iDimension = 1:size(ts, 2)
                smooth_timeseries = horzcat(smooth_timeseries, smooth(rescale(ts(:, iDimension), 1, 5)));
            end
        end
        
        function display_timeseries = findDisplayTimeseries(obj, ts)
    %         s = regions{iRegion}.timeseries;
    %         v = [diff(s(1:2,:)) ; s(3:end,:) - s(1:end-2,:) ; diff(s(end-1:end,:))] ./ 2;
    %         regions{iRegion}.display_timeseries = cumsum([0; v]);

            if size(ts, 2) > 1
                sx = ts(:,1);
                sy = ts(:,2);
    %             sy = max(sy) - sy + min(sy);

                display_timeseries = sqrt(sum([(max(sx) - sx) .^ 2, (max(sy) - sy) .^ 2], 2));
            else
                display_timeseries = smooth(rescale(ts, 1, 5));
            end
        end
        
        function obj = getRegionByArticulator(objArray, articulator)
            obj = objArray(strcmp([objArray.name], articulator));
        end
        
    end
end
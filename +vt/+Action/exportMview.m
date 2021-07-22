function [data] = exportMview(regions, video, varargin)
    p = inputParser;
    p.StructExpand = false;
    p.addRequired('regions');
    p.addRequired('video');
    p.addOptional('use_smooth_timeseries', 0);
    p.addOptional('timeseries_sampling_rate', video.frameRate);
    p.parse(regions, video, varargin{:});
    
    regions = p.Results.regions;
    video = p.Results.video;
    use_smooth_timeseries = p.Results.use_smooth_timeseries;
    timeseries_sampling_rate = p.Results.timeseries_sampling_rate;

	if isempty(regions) || ~numel(regions)
		% There are no regions saved right now, so there's nothing to
		% delete
		return;
	end

	wav_dir = 'wav';
	avi_dir = 'avi';
% 	velum_upordown = 'down';
	data.fps = video.frameRate;

    for iRegion = 1:numel(regions)
		region = regions{iRegion};
		
		type = lower(strrep(region.type, '-', '_'));
		switch (type)
			case 'centroid'
				if strcmp(region.timeseriesDimension, 'x')
                    if use_smoothed_timeseries
                        timeseries = region.smooth_timeseries(:, 1);
                    else
                        timeseries = region.timeseries(:, 1);
                    end
                else
                    if use_smooth_timeseries
                        timeseries = region.smooth_timeseries(:, 2);
                    else
                        timeseries = region.timeseries(:, 2);
                    end
				end
            otherwise
                if use_smooth_timeseries
                    timeseries = region.smooth_timeseries;
                else
                    timeseries = region.timeseries;
                end
		end

		data.gest(iRegion).name = region.name;
		data.gest(iRegion).location = region.origin;
		data.gest(iRegion).frames = 0:(video.nFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose). Needs to be the video framerate
		data.gest(iRegion).times = (0:(video.nFrames-1)) ./ video.frameRate; % Needs to be the video framerate, I'm pretty sure. Used for selecting the right range of audio samples in formatData

		% TODO: Put this filtering somewhere else
% 		disp(['Smoothing timeseries for region ' region.name '...']);
% 		interp = 1; % If you make this value bigger, you can interpolate additional points
% 		wwid = .9;
% 		X = 1:size(timeseries(:,1));
% 		Y = timeseries;
% 		D = linspace(min(X), max(X), (interp*max(X)))';
% 		[filtered_timeseries, ~] = lwregress3(X', Y, D, wwid);

% 		if (~isempty(strfind(lower(region.name), 'vel')) && strcmp(velum_upordown, 'down'))
% % 			smooth_ts = filtered_timeseries;
% 			smooth_ts = timeseries;
% 		else
% % 			smooth_ts = max(filtered_timeseries) - filtered_timeseries + min(filtered_timeseries);
% 			smooth_ts = max(timeseries) - timeseries + min(timeseries);
% 		end

        smooth_ts = timeseries;
		data.gest(iRegion).Ismoothed = smooth_ts;
% 		data.gest(iRegion).stimes = (D-1) ./ video.frameRate;
        data.gest(iRegion).timeseries_sampling_rate = timeseries_sampling_rate;
    end
%     disp('Finished smoothing.');

	filename = video.filename;
	[~, filename, ~] = fileparts(filename); % Make sure you're getting only the file name, not the extension
	data = vt.Action.formatData(data, filename, wav_dir, avi_dir, video);
    
%     [file, path] = uiputfile([filename '_mview.mat']);
% 			
%     if ~file
%         % The user canceled. Do nothing.
%         return
%     end
% 
% 	save(fullfile(path, file), 'data');
end
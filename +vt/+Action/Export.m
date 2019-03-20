classdef Export < redux.Action
	events
		EXPORT
	end
	
	properties
		regions
		video
	end
	
	methods
		function [] = prepare(this, regions, video)
			this.regions = regions;
			this.video = video;
		end
		
		function [] = dispatch(this)
			exportMview(this.regions, this.video);
		end
	end
end

function [] = exportMview(regions, video)
	if isempty(regions) || ~numel(regions)
		% There are no regions saved right now, so there's nothing to
		% delete
		return;
	end

	wav_dir = 'wav';
	avi_dir = 'avi';
	velum_upordown = 'down';
	data.fps = video.frameRate;

	for iRegion = 1:numel(regions)
		region = regions{iRegion};
		timeseries = region.timeseries;

		data.gest(iRegion).name = region.name;
		data.gest(iRegion).location = region.origin;
		data.gest(iRegion).frames = 0:(video.nFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose)
		data.gest(iRegion).times = (0:(video.nFrames-1)) ./ video.frameRate;

		% TODO: Put this filtering somewhere else
		disp(['Smoothing timeseries for region ' region.name '...']);
		interp = 1; % If you make this value bigger, you can interpolate additional points
		wwid = .9;
		X = 1:size(timeseries(:,1));
		Y = timeseries;
		D = linspace(min(X), max(X), (interp*max(X)))';
		[filtered_timeseries, ~] = lwregress3(X', Y, D, wwid);

		if (~isempty(strfind(lower(region.name), 'vel')) && strcmp(velum_upordown, 'down'))
			smooth_ts = filtered_timeseries;
		else
			smooth_ts = max(filtered_timeseries) - filtered_timeseries + min(filtered_timeseries);
		end
		data.gest(iRegion).Ismoothed = smooth_ts;
		data.gest(iRegion).stimes = (D-1) ./ video.frameRate;
	end

	filename = video.filename;
	[~, filename, ~] = fileparts(filename); % Make sure you're getting only the file name, not the extension
	data = formatData(data, filename, wav_dir, avi_dir);

	save(filename, 'data');
	disp('Finished smoothing.');
end

function d = formatData(v, fName, wav_dir, avi_dir)
	%FORMATDATA  - format rtMRI data for use with mviewRT
	%
	%	usage:  d = FormatData(v, fName, locNames)
	%
	% V is the rtMRI intensity data variable
	% FNAME maps to the associated WAV and AVI files
	%
	% optional LOCNAMES identifies the pixel intensity regions
	% (drawn from V.gest(n).name by default)

	% mkt 11/12
	% edited by Reed Blaylock 9/2015, 8/2017

	locNames = {v.gest.name};

	audio_name = [fName '.wav'];
	if nargin > 2
		audio_name = fullfile(wav_dir, audio_name);
	end

	video_name = [fName '.avi'];
	if nargin > 3
		video_name = fullfile(avi_dir, video_name);
	end

	% load audio
	try
		if exist('audioread', 'file'), [s,sr] = audioread(audio_name); else [s,sr] = wavread(audio_name); end
	catch
		error('unable to load WAV file %s',audio_name);
	end
	ht = floor(v.gest(1).times*sr) + 1;
	s = s(ht(1):ht(end));
	d = struct('NAME','AUDIO','SRATE',sr,'SIGNAL',s,'LOCATION',[]);

	% load images
	% TODO: You've already done this to load the video in the first
	% place, so just copy the video frames over...
	try
		h = VideoReader(video_name);
	catch
		error('unable to load AVI file %s',video_name);
	end
	frames = v.gest(1).frames + 1;		% 0- to 1-based
	try
		nfr = get(h,'numberOfFrames');
		img = read(h,frames([1 end]));
	catch
		error('unable to load frames %d:%d in %s (%d frames available)', frames, fn, nfr);
	end
	img = squeeze(img(:,:,1,:));
	d(end+1) = struct('NAME','IMAGE','SRATE',v.fps,'SIGNAL',img,'LOCATION',[]);

	% format output
	gsr = 1 / mean(diff(v.gest(1).stimes));
	for k = 1 : length(v.gest),
		d(end+1) = struct('NAME', locNames{k}, ...
					'SRATE', gsr, ...
					'SIGNAL', v.gest(k).Ismoothed, ...
					'LOCATION',v.gest(k).location);
	end
end
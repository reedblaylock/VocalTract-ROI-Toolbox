function d = formatData(v, fName, wav_dir, avi_dir, video)
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
	% edited by Reed Blaylock 9/2015, 8/2017, 3/2021
    
%     p = inputParser;
%     p.StructExpand = false;
%     p.addRequired('v');
%     p.addRequired('fName');
%     p.addOptional('wav_dir', 'wav');
%     p.addOptional('avi_dir', 'avi');
%     p.addOptional('video', struct());
%     p.parse(v, fName, varargin{:});
    
%     v = p.Results.v;
%     fName = p.Results.fName;
%     wav_dir = p.Results.wav_dir;
%     avi_dir = p.Results.avi_dir;
%     video = p.Results.video;

    % Put the data struct together
	locNames = {v.gest.name};

    audio_name = fullfile(wav_dir, [fName '.wav']);
	
    if ~exist(audio_name, 'file') == 2
		[file, path] = uigetfile('.wav', 'Select an audio file (.wav) to export with');
		audio_name = fullfile(path, file);
    end
    
%     video_name = fullfile(avi_dir, [fName '.avi']);
    video_name = fullfile(avi_dir, video.filename);

	% load audio
	try
		if exist('audioread', 'file')
			[s, sr] = audioread(audio_name);
% 		else
% 			[s, sr] = wavread(audio_name);
		end
	catch
		error('Unable to load WAV file %s', audio_name);
	end
	ht = floor(v.gest(1).times*sr) + 1;
	s = s(ht(1):ht(end));
	d = struct('NAME','AUDIO','SRATE',sr,'SIGNAL',s,'LOCATION',[]);

	% load images
	% You've already done this to load the video in the first
	% place, so just copy the video frames over...
    if ~numel(fieldnames(video))
        img = [];
        for iFrame = 1:video.nFrames
            img(:,:,iFrame) = reshape(video.matrix(1,:), video.height, video.width);
        end
    else
    % If that's not working for some reason, reload the video
        try
            h = VideoReader(video_name);
        catch
            error('unable to load file %s',video_name);
        end
        frames = v.gest(1).frames + 1;		% 0- to 1-based
        try
            nfr = get(h,'numberOfFrames');
            img = read(h,frames([1 end]));
        catch
            error('unable to load frames %d:%d in %s (%d frames available)', frames, fn, nfr);
        end
        img = squeeze(img(:,:,1,:));
    end

	d(end+1) = struct('NAME','IMAGE','SRATE',v.fps,'SIGNAL',img,'LOCATION',[]);

	% format output
% 	timeseries_sampling_rate = 1 / mean(diff(v.gest(1).stimes));
	for k = 1 : length(v.gest)
        timeseries_sampling_rate = v.gest(k).timeseries_sampling_rate;
		d(end+1) = struct('NAME', locNames{k}, ...
					'SRATE', timeseries_sampling_rate, ...
					'SIGNAL', v.gest(k).Ismoothed, ...
					'LOCATION',v.gest(k).location);
	end
end
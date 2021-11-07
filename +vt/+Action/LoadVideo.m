classdef LoadVideo < redux.Action
	events
		LOAD_VIDEO
	end
	
	properties
		video
	end
	
	methods
		function [] = prepare(this, loadType)
			p = inputParser;
			addRequired(p, 'loadType', @ischar);
			parse(p, loadType);
			
			disp('Loading video data...');
			
% 			try
				this.video = loadVideo(p.Results.loadType);
% 			catch excp
% 				this.log.exception(excp);
% 				% TODO: Do something about this
% 			end
		end
	end
end

function video = loadVideo(loadType)
    if strcmp(loadType, 'variable')
        prompts = { ...
            'Path to save outputs to:', ...
            'Filename if this variable were a video (but be careful not to overwrite an actual video):', ...
            'Video width:', ...
            'Video height:', ...
            'Number of frames:', ...
            'Framerate', ...
            'Name of variable holding the data' ...
        };
        default_input = { ...
            pwd, ...
            'video_name.avi', ...
            '84', ...
            '84', ...
            '1000', ...
            '83.2778', ...
            'my_variable' ...
        };
        input_response = inputdlg(prompts, 'Load video from workspace variable', 1, default_input);
        video = struct( ...
            'filename', input_response{2}, ...
            'fullpath', input_response{1}, ...
            'width', str2double(input_response{3}), ...
            'height', str2double(input_response{4}), ...
            'nFrames', str2double(input_response{5}), ...
            'frameRate', str2double(input_response{6}), ...
            'matrix', evalin('base', input_response{7}) ...
        );
    else
        [filename, pathname] = uigetfile('*.*', 'Select video file(s) to load', 'MultiSelect', 'on');
        if isequal(filename,0) || isequal(pathname,0)
            return;
        end
        
        if ~iscell(filename)
            filename = {filename};
%             pathname = {pathname};
        end
        
        nFiles = numel(filename);
        
        if nFiles > 1
            disp('Be advised: Loading videos with mismatched dimensions or framerates will result in unpredicatable results and errors.');
        end
        
        for iFile = 1:nFiles
            fullpath = fullfile(pathname, filename{iFile});
            disp(['Loading ' filename{iFile} '...']);

            % Check that the file exists
            if(exist(fullpath, 'file') ~= 2)
                excp = MException('VTToolbox:FileNotFound', 'The file you selected could not be found.');
                throw(excp);
            end

            % Check that the file really has extension loadType
%             [~, ~, ext] = fileparts(fullpath);
%             if(~strcmp(ext, ['.' loadType]))
%                 % Error: file is incorrect type
%                 excp = MException('VTToolbox:WrongExtension', ['The file you selected is not of type ' loadType '.']);
%                 throw(excp);
%                 % But maybe a user thought they wanted an AVI but actually
%                 % wanted a VT. Is it worth making them start again, or should
%                 % you load the VT but issue a notification that the target file
%                 % wasn't of the target file type?
%             end

%             switch(ext)
%                 case '.avi'
%                     vr = VideoReader(fullpath);
%                     matrix = vr2matrix(vr);
%                 otherwise
%                     % Error: unknown request type
%                     excp = MException('VTToolbox:InvalidExtension', ['File type ' ext ' is unknown.']);
%                     throw(excp);
%             end

            vr = VideoReader(fullpath);
            matrix = vr2matrix(vr);
            
            if iFile == 1
                video = struct( ...
                    'filename', filename{iFile}, ...
                    'fullpath', fullpath, ...
                    'width', vr.Width, ...
                    'height', vr.Height, ...
                    'nFrames', vr.NumberOfFrames, ...
                    'frameRate', vr.FrameRate, ...
                    'matrix', matrix ...
                ); %#ok<VIDREAD> vr.NumberOfFrames is still ok to use as of R2017a and R2020a
            else
                video.nFrames = video.nFrames + vr.NumberOfFrames; %#ok<VIDREAD> vr.NumberOfFrames is still ok to use as of R2017a and R2020a
                video.matrix = [video.matrix; matrix];
            end
        end
        
        if nFiles > 1
            video.filename = [video.filename '_andothers'];
        end
    end
end

% Adam Lammert (2010)
% Modified by Reed Blaylock (2014)
function [M] = vr2matrix(vr)
	% Get data from VideoReader
% 	if isOldMatlabVersion()
% 		vidFrames = read(vr);
% 	else
% 		while hasFrame(vr)
% 			vidFrames = readFrame(vr);
% 		end
% 	end

	vidFrames = read(vr);

	% Convert VideoReader output to something usable
	for k = 1:vr.NumberOfFrames
		mov(k).cdata = vidFrames(:,:,:,k); %#ok<AGROW>
		mov(k).colormap = []; %#ok<AGROW>
	end

	% Get movie information
	frame_height = vr.Height;
	frame_width = vr.Width;
	vec_length = frame_height*frame_width;

	% Reshape matrix
	M = zeros(vr.NumberOfFrames,vec_length);
	for itor = 1:vr.NumberOfFrames
		M(itor,:) = reshape(double(mov(itor).cdata(:,:,1)),1,vec_length);
	end

	% Normalize matrix
	M = M./repmat(mean(M,2),1,size(M,2));
end
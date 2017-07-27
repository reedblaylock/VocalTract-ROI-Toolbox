classdef Loader < vt.Root & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.Load
	end
	
	methods
		function video = loadVideo(this, loadType)
			[filename, pathname] = uigetfile(['*.' loadType], ['Select ' loadType ' file to load']);
			fullpath = fullfile(pathname, filename);
			
			% Check that the file exists
			if(exist(fullpath, 'file') ~= 2)
				% Error: file does not exist
			end
			
			% Check that the file really has extension loadType
			[~, ~, ext] = fileparts(fullpath);
			if(~strcmp(ext, ['.' loadType]))
				% Error: file is incorrect type
				% But maybe a user thought they wanted an AVI but actually
				% wanted a VT. Is it worth making them start again, or should
				% you load the VT but issue a notification that the target file
				% wasn't of the target file type?
			end
			
			switch(loadType)
				case 'avi'
					vr = VideoReader(fullpath);
					matrix = this.vr2matrix(vr);
				otherwise
					% Error: unknown request type
					disp('Error: Unknown load request. Loading has failed. Please try again.');
					return;
			end
			
			video = vt.Video( ...
				filename, ...
				fullpath, ...
				vr.Width, ...
				vr.Height, ...
				vr.NumberOfFrames, ...
				vr.FrameRate, ...
				matrix ...
			); %#ok<GENDEP> vr.NumberOfFrames is still ok to use as of R2017a
		
			this.action.dispatch(video);
		end

% 		Adam Lammert (2010)
% 		Modified by Reed Blaylock (2014)
		function [M] = vr2matrix(~, vr)
			% Get data from VideoReader
			vidFrames = read(vr);
			
% 			% sometimes, the last frame doesn't want to be read
% 			num_read_frames = size(vidFrames, 4);
% 			if num_read_frames ~= this.numFrames
% 				disp(['Only able to read ' num2str(num_read_frames) ' frames of ' num2str(this.numFrames) ' frames. Processing with ' num2str(num_read_frames) ' frames.']);
% 				this.numFrames = num_read_frames;
% 			end

			% Convert VideoReader output to something usable
			for k = 1 : vr.NumberOfFrames;
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
	end
end
classdef VideoLoader < vt.StateListener & vt.ActionDispatcherWithData
	events
		SET_VIDEO_DATA
	end
	
	methods
		function [] = update(this, ~, loadType)
			[filename, pathname] = uigetfile(['*.' loadType], ['Select ' loadType ' file to load']);
			file = fullfile(pathname, filename);
			
			% Check that the file exists
			if(exist(file, 'file') ~= 2)
				% Error: file does not exist
			end
			
			% Check that the file really has extension loadType
			[~, ~, ext] = fileparts(file);
			if(~strcmp(ext, ['.' loadType]))
				% Error: file is incorrect type
				% But maybe a user thought they wanted an AVI but actually
				% wanted a VT. Is it worth making them start again, or should
				% you load the VT but issue a notification that the target file
				% wasn't of the target file type?
			end
			
			switch(loadType)
				case 'avi'
					vr = VideoReader(file);
					vm = vr2matrix(vr);
				otherwise
					% Do nothing
			end
			
			% https://stackoverflow.com/questions/31988224/how-to-set-listener-to-a-matlab-objects-structures-field
			video = struct();
			video.width = vr.Width;
			video.height = vr.Height;
			video.nFrames = vr.NumberOfFrames; %#ok<GENDEP> % still good as of R2017a
			video.frameRate = vr.FrameRate;
			video.matrix = vm;
			video.currentFrame = 1;
			
			this.setData(video);
			
			this.dispatchAction();
		end
		
		function [M] = vr2Matrix(obj, vr)
% 			
% 			Adam Lammert (2010)
% 			Modified by Reed Blaylock (2014) to make compatible with VideoReader and
% 			to consolidate code
% 			
% 			Convert Avi file to Matrix of Frames
% 			
% 			INPUT 
% 			  vr: VideoReader object
% 			OUTPUT
% 			  M: the normalized movie matrix 
% 			      (rows are frames, columns are linearly indexed pixels)

			% Get data from VideoReader
			vidFrames = read(vr);
			
			% sometimes, the last frame doesn't want to be read
			num_read_frames = size(vidFrames, 4);
			if num_read_frames ~= obj.numFrames
				disp(['Only able to read ' num2str(num_read_frames) ' frames of ' num2str(obj.numFrames) ' frames. Processing with ' num2str(num_read_frames) ' frames.']);
				obj.numFrames = num_read_frames;
			end

			% Convert VideoReader output to something usable
			for k = 1 : num_read_frames;
				mov(k).cdata = vidFrames(:,:,:,k); %#ok<AGROW>
				mov(k).colormap = []; %#ok<AGROW>
			end

			% Get movie information
			frame_height = vr.Height;
			frame_width = vr.Width;
			vec_length = frame_height*frame_width;

			% Reshape matrix
			M = zeros(obj.numFrames,vec_length);
			for itor = 1:obj.numFrames
				M(itor,:) = reshape(double(mov(itor).cdata(:,:,1)),1,vec_length);
			end

			% Normalize matrix
			M = M./repmat(mean(M,2),1,size(M,2));
		end
	end
end

% MenuItem (load) --> callback event --> Reducer --> State.isLoading --> PropSet event --> Loader --> emit action --> Reducer.setVideoData --> PropSet event --> vt.Axes.redraw()
% 
% reducer.addActionListener( LoadAviMenuItem, 'LOAD', 'avi' )
% loader.addStateListener( state, 'isLoading' )
% reducer.addActionListener( Loader, 'SET_VIDEO_DATA', videoData )
classdef VideoLoader < handle
	
	properties
% 		filename
% 		vidMatrix
% 		framerate
% 		numFrames
% 		width
% 		height
% 		silence_start
% 		silence_end
	end
	
	methods
		function [] = redraw(this, ~, loadType)
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
			
			video = struct();
			video.width = vr.Width;
			video.height = vr.Height;
			video.nFrames = vr.NumberOfFrames; %#ok<GENDEP> % still good as of R2017a
			video.frameRate = vr.FrameRate;
			video.matrix = vm;
			video.currentFrame = 1;
			
			this.dispatchAction('SET_VIDEO_DATA', video);
		end
		
		function [] = dispatchAction(this, action, data)
			eventdata = vt.EventData(data);
			notify(this, action, eventdata);
		end
		
% 		function [obj] = Video(varargin)
% 			% Number of inputs must be >=1 and <=4
% 			narginchk(1,4);
% 			silence_start = [];
% 			silence_end = [];
% 			
% 			if isnumeric(varargin{1})
% 				% first argument is a matrix
% 				[h, w, f] = size(varargin{1});
% 				obj.height = h;
% 				obj.width = w;
% 				obj.numFrames = f;
% 				pre_vm = varargin{1};
% 				vec_length = h*w;
% 
% 				% Reshape matrix
% 				M = zeros(obj.numFrames,vec_length);
% 				for itor = 1:obj.numFrames
% 					M(itor,:) = reshape(double(pre_vm(:,:,itor)),1,vec_length);
% 				end
% 				
% 				% Normalize matrix
% 				vm = M./repmat(mean(M,2),1,size(M,2));
% 				
% 				% there must be a second argument, and it must be a float
% 				if nargin < 2 || ~isnumeric(varargin{2}) || varargin{2} == 0 || varargin{2} == 1
% 					error('Second argument must be a frame rate');
% 				else
% 					obj.framerate = varargin{2};
% 				end
% 				
% 				% there must be a third argument, and it must be a string
% 				if nargin < 3 || isnumeric(varargin{3}) || ~isempty(strfind(varargin{3}, '.'))
% 					error('Third argument must be a name for this data (without extension).');
% 				else
% 					obj.filename = varargin{3};
% 				end
% 				
% 				% optional boolean fourth argument controls normalization
% 				if nargin > 3
% 					if varargin{4} == 1
% 						obj.vidMatrix = Normalizer.normalize(vm);
% 						disp('normalizing now');
% 					else
% 						obj.vidMatrix = vm;
% 					end
% 				else
% 					obj.vidMatrix = vm;
% 				end
% 				
% 			else
% 				% first argument is a string
% 				
% 				if nargin > 2
% 					error('Too many input arguments');
% 				end
% 				
% 				parts = strsplit(varargin{1}, '.');
% 				name = parts(1);
% 				if size(parts, 2) < 2
% 					ext = 'avi';
% 				else
% 					ext = parts(2);
% 				end
% 
% 				f = cellstr(strjoin(cellstr([name, ext]), '.')); % just [x y] strcat?
% 				obj.filename = f{1};
% 
% 				vr = VideoReader(obj.filename);
% 				obj.numFrames = vr.NumberOfFrames;
% 				obj.framerate = vr.FrameRate;
% 				vm = obj.vr2Matrix(vr);
% 
% 				if nargin > 1 && varargin{2}
% 					obj.vidMatrix = Normalizer.normalize(vm);
% 					disp('normalizing now');
% 				else
% 					obj.vidMatrix = vm;
% 				end
% 
% 				obj.width = vr.Width;
% 				obj.height = vr.Height;
% 			end
% 		end
		
% 		function [meanimage] = mean_image(obj)
% 			meanimage = reshape(mean(obj.vidMatrix,1),obj.width,obj.height);
% 		end
% 		
% 		function [stdimage] = std_image(obj)
% 			stdimage = reshape(std(obj.vidMatrix,1),obj.width,obj.height);
% 		end
% 		
% 		function [image] = frame(obj, n)
% 			image = reshape(obj.vidMatrix(n,:),obj.width,obj.height);
% 		end
		
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
classdef LoadVideo < vt.Action
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
			
			try
				this.video = loadVideo(p.Results.loadType);
			catch excp
				this.log.exception(excp);
				% TODO: Do something about this
			end
		end
	end
end

function video = loadVideo(loadType)
	[filename, pathname] = uigetfile(['*.' loadType], ['Select ' loadType ' file to load']);
	if isequal(filename,0) || isequal(pathname,0)
		return
	end
	fullpath = fullfile(pathname, filename);

	% Check that the file exists
	if(exist(fullpath, 'file') ~= 2)
		excp = MException('VTToolbox:FileNotFound', 'The file you selected could not be found.');
% 		this.log.exception(excp);
		throw(excp);
% 		return
	end

	% Check that the file really has extension loadType
	[~, ~, ext] = fileparts(fullpath);
	if(~strcmp(ext, ['.' loadType]))
		% Error: file is incorrect type
		excp = MException('VTToolbox:WrongExtension', ['The file you selected is not of type ' loadType '.']);
% 		this.log.exception(excp);
		throw(excp);
% 		return
		% But maybe a user thought they wanted an AVI but actually
		% wanted a VT. Is it worth making them start again, or should
		% you load the VT but issue a notification that the target file
		% wasn't of the target file type?
	end

	switch(ext)
		case '.avi'
			vr = VideoReader(fullpath);
			matrix = vr2matrix(vr);
		otherwise
			% Error: unknown request type
			excp = MException('VTToolbox:InvalidExtension', ['File type ' ext ' is unknown.']);
			throw(excp);
% 			this.log.exception(excp);
% 			return
	end

	video = struct( ...
		'filename', filename, ...
		'fullpath', fullpath, ...
		'width', vr.Width, ...
		'height', vr.Height, ...
		'nFrames', vr.NumberOfFrames, ...
		'frameRate', vr.FrameRate, ...
		'matrix', matrix ...
	); %#ok<GENDEP> vr.NumberOfFrames is still ok to use as of R2017a
end

% function b = isOldMatlabVersion()
% 	newVersionDate = '08-Sep-2014';
% 	matlabVersion = ver( 'MATLAB' );
% 	b = datenum( matlabVersion.Date ) < datenum( newVersionDate );
% end

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
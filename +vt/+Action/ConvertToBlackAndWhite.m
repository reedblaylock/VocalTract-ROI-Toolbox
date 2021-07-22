classdef ConvertToBlackAndWhite < redux.Action
	events
		CONVERT_TO_BLACK_AND_WHITE
	end
	
	properties
		video
	end
	
	methods
		function [] = prepare(this, video)
			p = inputParser;
			addRequired(p, 'video', @isstruct);
			p.StructExpand = false;
			parse(p, video);
			
			try
				this.video = convertToBlackAndWhite(p.Results.video);
			catch excp
				this.log.exception(excp);
				% TODO: Do something about this
			end
		end
	end
end

function converted_video = convertToBlackAndWhite(video)
	converted_video = video;
	converted_video.matrix = im2bw(mat2gray(imquantize( ...
		video.matrix, multithresh(video.matrix, 1) ...
	)));

%  % fill holes. doesn't work great
%     for iFrame = 1:size(converted_video.matrix, 1)
%         frame = reshape(converted_video.matrix(iFrame, :), video.height, video.width);
%         frame = imfill(frame, 'holes');
%         converted_video.matrix(iFrame, :) = reshape(frame, 1, video.height * video.width);
%     end
end
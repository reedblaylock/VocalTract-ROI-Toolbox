classdef CorrectHeadMovement < redux.Action
	events
		CORRECT_HEAD_MOVEMENT
	end
	
	properties
		videoWithHeadMovementCorrection
	end
	
	methods
		function [] = prepare(this, video)
			p = inputParser;
			addRequired(p, 'video', @isstruct);
			p.StructExpand = false;
			parse(p, video);
			
			disp('Correcting head movement...');
			
% 			try
				this.videoWithHeadMovementCorrection = correctHeadMovementLESA(p.Results.video);
% 			catch excp
% 				this.log.exception(excp);
% 				% TODO: Do something about this
% 			end

            disp('Finished correcting head movement.');
		end
	end
end

function corrected_video = correctHeadMovementLESA(video)

	corrected_video_matrix = zeros(size(video.matrix));

	% orignal_noses = zeros(video.nFrames, 2);
	% orginal_chins = zeros(video.nFrames, 2);
	% rotated_noses = zeros(video.nFrames, 2);
	% rotated_chins = zeros(video.nFrames, 2);

	frameNo = 1;
	first_img = reshape( ...
		video.matrix(frameNo,:), ...
		video.width, ...
		video.height ...
	);

	[nose_target, chin_target] = get_nose_and_chin(first_img);

	corrected_video_matrix(1, :) = first_img(:)';

	for nextFrameNo = 2:video.nFrames

		new_img = reshape( ...
			video.matrix(nextFrameNo,:), ...
			video.width, ...
			video.height ...
		);

		[nose_to_be_corrected, chin_to_be_corrected] = get_nose_and_chin(new_img);

		corrected_img = correctImage(new_img, nose_target, chin_target, nose_to_be_corrected, chin_to_be_corrected);

		corrected_video_matrix(nextFrameNo, :) = corrected_img(:)';
	end

	corrected_video = video;
	corrected_video.matrix = corrected_video_matrix;

end

function corrected_image = correctImage(image_to_be_corrected, nose_target, chin_target, nose_to_be_corrected, chin_to_be_corrected)

	% translate image
	translation_method = 'linear'; %cubic, nearest
	translation_vector = nose_target - nose_to_be_corrected;
	image_to_be_rotated = imtranslate(image_to_be_corrected, translation_vector, 'method', translation_method);

	% get rotation angle
	x1 = nose_to_be_corrected(1); y1 = nose_to_be_corrected(2);
	x2 = chin_to_be_corrected(1); y2 = chin_to_be_corrected(2);
	x3 = nose_target(1); y3 = nose_target(2);
	x4 = chin_target(1); y4 = chin_target(2);
	% u=[x2,y2]-[x1,y1];
	% v=[x4,y4]-[x3,y3];
	% ThetaInDegrees = atan2d(norm(cross(u,v)),dot(u,v));

	ThetaInDegrees = (atan((y2-y1)/(x2-x1)) - atan((y4-y3)/(x4-x3))) * 180/pi;

	% rotate the image
	method = 'nearest'; %bilinear, bicubic
	corrected_image = rotateAround(image_to_be_rotated, nose_target(2), nose_target(1), ThetaInDegrees, method);

end

function [nose, chin] = get_nose_and_chin(img)

	img = im2bw(mat2gray(imquantize(img, multithresh(img, 1))));

	[ptsr,ptsc] = find(img);
	pts = [ptsr ptsc];
	lesa = computeLESA(pts);

	th = 195;
	pts_th = pts(lesa > th, :);
	idx = sortRadially(pts_th);
% 	plot(pts_th(idx,2),pts_th(idx,1),'r*-');hold off;
	vtxs = pts_th(idx, :);
	nose = vtxs(1, :);
	chin = vtxs(end-1, :);
	
% 	x = pts_th(idx, 2); y = pts_th(idx, 1);
% 	x = [x(1) x(end-1)]; y = [y(1) y(end-1)];
% 	plot(x,y,'r*-');hold off;

end
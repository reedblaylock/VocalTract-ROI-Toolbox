classdef (Sealed) State < handle
	% SetObservable emits PreSet and PostSet events.
	%
	% AbortSet will prevent the PostSet event from being emitted based on
	% isequal(). Non-static objects will not be considered equal, even if their
	% property values are identical.
	properties (SetObservable = true, AbortSet = true)
		video
		currentFrame
	end
	
	methods (Access = private)
% 		function this = vt.State()
% 			
% 		end
	end
	
% 	methods (Static)
% 		function state = getInstance()
% 			% Problem: this keeps state in storage even after the GUI closes. 
% 			% Half-solution: clear State on window close
% 			% Also, apparently the state can't be saved this way? https://www.mathworks.com/help/matlab/matlab_oop/static-data.html
% 			persistent localObj
% 			if isempty(localObj) || ~isvalid(localObj)
% 				localObj = vt.State;
% 			end
% 			state = localObj;
% 		end
% 	end
	
	methods
		function this = State()
			
		end
		
		function [] = initialize(this)
			this.video = [];
			this.currentFrame = 0;
		end
	end
	
end


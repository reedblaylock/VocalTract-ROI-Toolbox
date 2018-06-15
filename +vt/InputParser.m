classdef InputParser < inputParser
	methods
		function [] = addParent(this)
			fcn = @(parent) isa(parent, 'vt.Component');
			this.addRequired('parent', fcn);
		end
		
		function [] = addParameter(this, paramName, defaultValue, varargin)
			if vt.Config.isOldMatlabVersion()
				addParamValue(this, paramName, defaultValue, varargin{:});
			else
				addParameter@inputParser(this, paramName, defaultValue, varargin{:});
			end
		end
	end
	
end


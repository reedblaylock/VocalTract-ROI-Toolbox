classdef InputParser < inputParser
	methods
		function [] = addParent(this)
			fcn = @(parent) isa(parent, 'vt.Component');
			this.addRequired('parent', fcn);
		end
		
		function [] = addParameter(this, paramName, defaultValue, varargin)
			if( this.isOldMatlabVersion() )
				addParamValue(this, paramName, defaultValue, varargin{:});
			else
				addParameter@inputParser(this, paramName, defaultValue, varargin{:});
			end
		end
		
		function b = isOldMatlabVersion(~)
			newVersionDate = '08-Sep-2014';
			matlabVersion = ver( 'MATLAB' );
			b = datenum( matlabVersion.Date ) < datenum( newVersionDate );
		end
	end
	
end


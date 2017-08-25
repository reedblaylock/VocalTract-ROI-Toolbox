classdef (Abstract) Root < handle
	properties (SetObservable)
% 		log = vt.Log(true);
		log
	end	
	
	methods
		function b = isOldMatlabVersion(~)
			newVersionDate = '08-Sep-2014';
			matlabVersion = ver( 'MATLAB' );
			b = datenum( matlabVersion.Date ) < datenum( newVersionDate );
		end
	end
end


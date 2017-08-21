classdef (Abstract) Layout < vt.Component
	
	properties
	end
	
	methods
		function this = Layout(parent, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addParent();
			parse(p, parent, varargin{:});
			
			this.construct(p.Results.parent);
			
			this.setParameters(varargin{:});
		end
	end
	
	methods (Access = protected)
		[] = construct(this, parent);
		
		function b = isOldMatlabVersion(~)
			newVersionDate = '08-Sep-2014';
			matlabVersion = ver( 'MATLAB' );
			b = datenum( matlabVersion.Date ) < datenum( newVersionDate );
		end
	end
	
end


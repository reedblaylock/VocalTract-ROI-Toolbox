classdef Empty < vt.Component.Layout
	methods
		function this = Empty(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			minVersionDate = '08-Sep-2014';
			matlabVersion = ver( 'MATLAB' );
			if datenum( matlabVersion.Date ) < datenum( minVersionDate )
				% Use the old version of the GUI Layout Toolbox
				this.handle = guilayouttoolbox.old.uiextras.Empty( ...
					'Parent', p.Results.parent.handle ...
				);
			else
				% Use the new version of the GUI Layout Toolbox
				this.handle = guilayouttoolbox.new.uix.Empty( ...
					'Parent', p.Results.parent.handle ...
				);
			end
		end
	end
end


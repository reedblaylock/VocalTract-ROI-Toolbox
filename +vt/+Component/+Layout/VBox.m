classdef VBox < vt.Component.Layout
	methods
		function this = VBox(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
		
		function [] = setParameters(this, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout'));
			parse(p, this, varargin{:});
			
			s = p.Unmatched;
			
			if( this.isOldMatlabVersion() )
				% Change Widths to Sizes
				nameToChange = 'Heights';
				nameReplacement = 'Sizes';
				s = this.renameField(s, nameToChange, nameReplacement);
				
				% Change MinimumWidths to MinimumSizes
				nameToChange = 'MinimumHeights';
				nameReplacement = 'MinimumSizes';
				s = this.renameField(s, nameToChange, nameReplacement);
				
				% Change Contents to Children
				nameToChange = 'Contents';
				nameReplacement = 'Children';
				s = this.renameField(s, nameToChange, nameReplacement);
			end
			
			c = this.struct2interleavedCell(s);
			setParameters@vt.Component.Layout(this, c{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.VBox'));
			p.addParent();
			parse(p, this, parent);
			
% 			this.handle = uiextras.VBox( ...
% 				'Parent', parent.handle ...
% 			);
			if ( this.isOldMatlabVersion() )
				this.handle = uiextras.VBox( ...
					'Parent', parent.handle ...
				);
			else
				this.handle = uix.VBox( ...
					'Parent', parent.handle ...
				);
			end
		end
	end
	
end


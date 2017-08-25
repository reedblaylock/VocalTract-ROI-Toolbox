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
		
		function s = renameField(~, s, oldName, newName)
			fields = fieldnames(s);
			if( find(ismember(fields, oldName)) )
				[s.(newName)] = s.(oldName);
				s = rmfield(s, oldName);
			end
		end
		
		% From the comments of https://www.mathworks.com/matlabcentral/fileexchange/16919-interleave
		function c = struct2interleavedCell(~, s)
			fields = fieldnames(s);
			values = struct2cell(s);
			
			c = cell(2, max(numel(fields), numel(values)));
			c(1, 1:numel(fields)) = num2cell(fields);
			c(2, 1:numel(values)) = num2cell(values);
			c = [c{:}];
			
			if( isempty(c) )
				c = {};
			end
		end
	end
	
	methods (Access = protected)
		[] = construct(this, parent);
	end
end


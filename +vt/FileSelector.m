classdef FileSelector < vt.Root
	methods
		function [filename, fullpath] = selectSingleFile(this, loadType)
			p = vt.InputParser;
			p.addRequired('loadType', @ischar);
			parse(p, loadType);
			
			loadType = p.Results.loadType;
			[filename, pathname] = uigetfile(['*.' loadType], ['Select ' loadType ' file to load']);
			
			if isequal(filename,0) || isequal(pathname,0)
				return
			end
			fullpath = fullfile(pathname, filename);
			
			% Check that the file exists
			if(exist(fullpath, 'file') ~= 2)
				excp = MException('VTToolbox:FileNotFound', 'The file you selected could not be found.');
% 				this.log.exception(excp);
				throw(excp);
% 				return
			end
			
			% Check that the file really has extension loadType
			[~, ~, ext] = fileparts(fullpath);
			if(~strcmp(ext, ['.' loadType]))
				% Error: file is incorrect type
				excp = MException('VTToolbox:WrongExtension', ['The file you selected is not of type ' loadType '.']);
% 				this.log.exception(excp);
				throw(excp);
% 				return
				% But maybe a user thought they wanted an AVI but actually
				% wanted a VT. Is it worth making them start again, or should
				% you load the VT but issue a notification that the target file
				% wasn't of the target file type?
			end
		end
		
		function [filenames, fullpaths] = selectMultiFile(this, loadType)
			p = vt.InputParser;
			p.addRequired('loadType', @ischar);
			parse(p, loadType);
			
			loadType = p.Results.loadType;
			[filenames, pathname] = uigetfile(['*.' loadType], ['Select ' loadType ' file to load'], 'MultiSelect', 'on');
			
			if(~iscell(filenames))
				filenames = {filenames};
			end
			
			fullpaths = cell(numel(filenames), 1);
			for iFile = 1:numel(filenames)
				filename = filenames{iFile};
				
				if isequal(filename,0) || isequal(pathname,0)
					return
				end
				fullpath = fullfile(pathname, filename);
				fullpaths{iFile} = fullpath;

				% Check that the file exists
				if(exist(fullpath, 'file') ~= 2)
					excp = MException('VTToolbox:FileNotFound', 'The file you selected could not be found.');
	% 				this.log.exception(excp);
					throw(excp);
	% 				return
				end

				% Check that the file really has extension loadType
				[~, ~, ext] = fileparts(fullpath);
				if(~strcmp(ext, ['.' loadType]))
					% Error: file is incorrect type
					excp = MException('VTToolbox:WrongExtension', ['The file you selected is not of type ' loadType '.']);
	% 				this.log.exception(excp);
					throw(excp);
	% 				return
					% But maybe a user thought they wanted an AVI but actually
					% wanted a VT. Is it worth making them start again, or should
					% you load the VT but issue a notification that the target file
					% wasn't of the target file type?
				end
			end
		end
	end
end


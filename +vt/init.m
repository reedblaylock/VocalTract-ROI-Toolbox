% This function runs the VocalTract ROI Toolbox. This is the only function you
% need to explicitly call in the MATLAB command line.
function [app] = init()
	close all force;
	clear;
	
	warning on backtrace;
	warning on all;
	warning on verbose;
	
	s = warning('error', 'MATLAB:callback:error'); %#ok<CTPCT>
	warning('error', 'MATLAB:class:InvalidHandle'); %#ok<CTPCT>
	
	fpath = mfilename('fullpath');
	fparts = regexp(fpath, filesep, 'split');
	packageName = fparts{end-1};
	if strcmp(packageName(1), '+')
		packageName = packageName(2:end);
	end
	
	app = vt.App(0);
	app.run(packageName);
	
	warning(s);
end
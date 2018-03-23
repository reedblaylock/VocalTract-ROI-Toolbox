% This function runs the VocalTract ROI Toolbox. This is the only function you
% need to explicitly call in the MATLAB command line.
function vttoolbox()
	close all force;
	clear;
	
	warning on backtrace;
	warning on all;
	warning on verbose;
	
	s = warning('error', 'MATLAB:callback:error');
	warning('error', 'MATLAB:class:InvalidHandle');
	
	app = vt.App(2);
	app.run();
	
	warning(s);
end
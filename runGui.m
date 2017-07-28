function runGui()
	close all force;
	clear;
	
	warning on backtrace;
	warning on all;
	warning on verbose;
	
	s = warning('error', 'MATLAB:callback:error');
	warning('error', 'MATLAB:class:InvalidHandle');
	
	gui = vt.Gui();
	gui.run();
	
	warning(s);
end
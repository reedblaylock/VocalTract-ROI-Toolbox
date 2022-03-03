% Other code needed
% - mPraat (but if you want to build your own TextGrid thingy, you can)
% - Vocal Tract ROI Toolbox (for the regions)

% work with a single video
% config sets everything else based on basepath

% Define important configuration information
configSettings.basepath = 'C:/Users/reedb/Google Drive/USC/Beatboxing/SPAN - Beatboxing_Nimisha/Data/Videos/jr/';
configSettings.basename = 'Humming_while_Beatboxing';

configSettings.wav_folder = 'wav';
configSettings.textgrid_folder = 'textgrid_out';
configSettings.avi_folder = 'avi';
configSettings.manual_gest_folder = 'manual_gest';
configSettings.regions_folder = 'regions';
configSettings.gestural_scores_folder = 'gestural_scores';
configSettings.image_out_folder = 'images';
% drumtab_folder = 'drumtabs';

configSettings.default_regions_file = 'jr_all_beats_regions.mat';

configSettings.phoneTier = 'phones';

configSettings.use_smooth_timeseries = false;

            % DelimitGest defaults
%             thresh = .2;
%             onsThr = .2;
%             offsThr = .15;
%             thrGons = thresh;
%             thrNons = thresh;
%             thrNoff = thresh;
%             thrGoff = thresh;

            % How I usually run things
            % onsThr and offsThr of 0.1 so far get me the most reliable
            % larynx gestures (after the time series is smooth()-ed)
%             onsThr = 0.1;
%             offsThr = 0.1;
%             thrGons = 0.2;
%             thrNons = 0.2;
%             thrNoff = 0.2;
%             thrGoff = 0.2;

%             % For ODE
%             onsThr = 0.2;
%             offsThr = 0.2;
configSettings.delimitGest.onsThr = 0.1;
configSettings.delimitGest.offsThr = 0.1;
configSettings.delimitGest.thrGons = 0.2;
configSettings.delimitGest.thrNons = 0.2;
configSettings.delimitGest.thrNoff = 0.2;
configSettings.delimitGest.thrGoff = 0.2;
configSettings.delimitGest.ht = [];


% Plot settings (note, these are strings, not chars)
configSettings.plot.all_timeseries_display_order = ["LAB" "LAB2" "COR" "COR2" "PAL" "PAL2" "DOR" "PHAR" "VEL" "LAR" "LAR2"];
configSettings.plot.include_timeseries = [];%["COR", "DOR"];
configSettings.plot.exclude_timeseries = [];%["PAL2", "PAL", "LAR2"];

% Put configuration settings into an object (quietly loads tables based on
% the configuration information)
config = gs.Config(configSettings);

% Gather the TextGrid, video, regions, and manually-corrected gestures
tg = gs.TextGrid(config.fname.textgrid).trim(config.start_cut_time, config.end_cut_time);
video = gs.Video(config.fname.avi);
regions = gs.Region(config.fname.regions, video);

% Prepare to do work. At this point, be able to look at the command window 
% for errors telling you what kinds of operations will/won't be available 
% based on which files from config actually exist
f = gs.File(config);

if config.manualGesturesExist()
    manualGestures = gs.ManualGesture(config.fname.manual_gest, config.use_smooth_timeseries, regions, video.frameRate);
    f = f.work(tg, video, regions, manualGestures);
else
    f = f.work(tg, video, regions);
end

% Plot the gestural score for this whole file
plot_url = f.plotly('Sample Gestural Score') % or plot(f), vs f.plotly()

% f.phones.gif(config, video, gs.ImageTask)

% Render the file as a table, with phones and gestures
tbl = table(f)
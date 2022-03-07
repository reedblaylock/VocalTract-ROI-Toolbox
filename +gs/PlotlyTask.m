classdef PlotlyTask
    
    methods
        function obj = PlotlyTask()
            % later
        end
        
        function setup(obj)
            % username = '';
            % token = '';
            % plotlysetup(username, token);
            % plotly_path = fullfile(pwd, 'plotly');
            % addpath(genpath(plotly_path));
            % saveplotlycredentials(username, token);
            % getplotlyoffline('http://cdn.plot.ly/plotly-latest.min.js');
        end
        
        function plot_url = work(obj, config, start_cut_time, end_cut_time, video_frameRate, phones, gestures, regions, textgrid_labels, textgrid_label_times, plot_title)%, audio, fs_wav)%, textgrid_label_time_samples, meter_labels)
            all_articulators = flip(config.plot.all_timeseries_display_order);
            
            start_cut_idx = floor(start_cut_time * video_frameRate) + 1;
            end_cut_idx = floor(end_cut_time * video_frameRate) + 1;

            articulators = unique([gestures.articulator]);
            if ~isempty(config.plot.include_timeseries)
                articulators = union(articulators, config.plot.include_timeseries, 'stable');
            end
            
            if ~isempty(config.plot.exclude_timeseries)
                articulators = setdiff(articulators, config.plot.exclude_timeseries, 'stable');
            end
            
            articulators = all_articulators(ismember(all_articulators, articulators));

            plotly_data = {};

            % Start the layout specs
            layout = initializeLayout(obj, plot_title);

            nYAxes = 0;

%             [layout, plotly_data] = obj.addWavAxis(layout, plotly_data, audio, fs_wav, start_cut_time, end_cut_time, nYAxes);
            
            for iArticulator = 1:length(articulators)
                art = articulators(iArticulator);
                region = regions.getRegionByArticulator(art);

                nYAxes = nYAxes + 1;

                color_as_rgb = obj.color_percent_to_rgb(region.color);

                s = region.display_timeseries;
                if size(s, 2) == 2
                    s = s(:, 2);
                end
                s = rescale(s);

                maxy = max(s);

                gests = gestures([gestures.articulator] == art);
                for iGest = 1:size(gests, 1)
                    gest_trace = obj.create_gest_trace(gests(iGest), video_frameRate, maxy, color_as_rgb, nYAxes);
                    plotly_data = [plotly_data(:)', {gest_trace}];
                end

                timeseries_trace = obj.create_timeseries_trace(start_cut_idx, end_cut_idx, video_frameRate, s, color_as_rgb, nYAxes, art);

                plotly_data = [plotly_data(:)', {timeseries_trace}];

                for iGest = 1:size(gests, 1)
                    maxc_label = phones([phones.local_ID] == gests(iGest).phone_ID).label;
                    maxc_trace = obj.create_maxc_trace(gests(iGest), maxc_label, video_frameRate, s, nYAxes);%, iArticulator, articulators);
                    plotly_data = [plotly_data(:)', {maxc_trace}];
                end

                transcription_trace = obj.create_transcription_trace(textgrid_label_times, textgrid_labels, nYAxes);
                plotly_data = [plotly_data(:)', {transcription_trace}];

                if nYAxes == 1
                    YAxis = 'yaxis';
                else
                    YAxis = ['yaxis' num2str(nYAxes)];
                end
                layout.(YAxis).title.text = char(art);
                layout.(YAxis).title.font.size = 20;
                layout.(YAxis).range = [-0.3 1.2];
                layout.(YAxis).showgrid = false;
            end

            % Add meter axis
%             [nYAxes, plotly_data, layout] = obj.addMeterAxis(nYAxes, plotly_data, layout, meter_labels, textgrid_label_times, textgrid_labels, textgrid_label_time_samples);

            % Format all axes
            layout = obj.formatAxes(nYAxes, layout);

        %     % Multiple graphs on separate axes in plotly:
        %     % https://plotly.com/matlab/subplots/#simple-subplot--multiple-graphs-on-separate-axes
            plotly_filename = plot_title;
            response = plotly(plotly_data, struct('layout', layout, 'filename', plotly_filename, 'fileopt', 'overwrite'));
            plot_url = response.url;
            
            % plotlyOffline(obj, plotly_data, layout)
        end
        
        function layout = initializeLayout(obj, plot_title)
            layout.title = plot_title;
            % make the legend run horizontally instead of vertically
            layout.legend = struct( ...
                'traceorder', 'reversed', ...
                'orientation', 'h', ...
                'yanchor', 'bottom', ...
                'y', 1, ...
                'xanchor', 'right', ...
                'x', 1 ...
            );
            layout.xaxis.showgrid = false;
            layout.xaxis.title.text = 'TIME';
            layout.xaxis.title.font.size = 20;
            layout.xaxis.ticksuffix = ' seconds';
        end
        
        function [layout, plotly_data] = addWavAxis(obj, layout, plotly_data, audio, fs_wav, start_cut_time, end_cut_time, nYAxes)
            nYAxes = nYAxes + 1;
            YAxis = 'yaxis';
            [wav_trace, layout] = obj.create_wav_trace(layout, audio, fs_wav, start_cut_time, end_cut_time, nYAxes, YAxis);
            plotly_data = [plotly_data(:)', {wav_trace}];
        end
        
        function [wav_trace, layout] = create_wav_trace(obj, layout, audio, fs_wav, start_cut_time, end_cut_time, nYAxes, YAxis)
            new_fs = fs_wav;
            new_audio = audio;
        %         new_fs = 11025;
        %         new_audio = resample(y, new_fs, fs);
        %         wav_squash_x = (1:length(new_audio)) * (video.frameRate/new_fs);
            wav_start_cut_idx = floor(start_cut_time * new_fs) + 1;
            wav_end_cut_idx = floor(end_cut_time * new_fs) + 1;

            if wav_end_cut_idx > length(new_audio)
                wav_end_cut_idx = length(new_audio);
                disp('create_wav_trace(): Calculated end index of wav was too large. Lowered it to equal the length of the audio. Only affects plots, not measurements.');
            end

            wav_x = (0:(length(new_audio)-1)) / new_fs;
            wav_x = wav_x(wav_start_cut_idx:wav_end_cut_idx);
            wav_y = new_audio(wav_start_cut_idx:wav_end_cut_idx);

        %         'x', wav_squash_x(wav_start_cut_idx:wav_end_cut_idx), ...
        %         'y', new_audio(wav_start_cut_idx:wav_end_cut_idx), ...
            wav_trace = struct( ...
                'x', wav_x, ...
                'y', wav_y, ...
                'marker', struct( ...
                    'color', 'rgba(0, 0, 0, 1)', ...
                    'line', struct( ...
                        'color', 'rgba(0, 0, 0, 1)' ...
                    ) ...
                ), ...
                'name', 'audio', ...
                'yaxis', ['y' num2str(nYAxes)], ...
                'type', 'scatter' ...
            );
            layout.(YAxis).title.text = 'AUDIO';
            layout.(YAxis).title.font.size = 20;
            layout.(YAxis).showgrid = false;
        end
        
        function timeseries_trace = create_timeseries_trace(obj, start_cut_idx, end_cut_idx, video_frameRate, s, color_as_rgb, nYAxes, art)
            if end_cut_idx > length(s)
                end_cut_idx = length(s);
                disp('create_timeseries_trace(): end_cut_idx was too large. Changed it to the max of the thing it indexes. Probably just a cosmetic problem.');
            end

            timeseries_trace = struct(...
                'x', (start_cut_idx:end_cut_idx)' / video_frameRate, ...
                'y', s(start_cut_idx:end_cut_idx), ...
                'marker', struct( ...
                    'color', color_as_rgb, ...
                    'line', struct( ...
                        'color', color_as_rgb ...
                    ) ...
                ), ...
                'line', struct( 'width', 5 ), ...
                'yaxis', ['y' num2str(nYAxes)], ...
                'showlegend', true, ...
                'name', char(art), ...
                'type', 'scatter' ...
            );
        end
        
        function maxc_trace = create_maxc_trace(obj, gest, label, video_frameRate, s, nYAxes)%, iArticulator, articulators)
            maxc_x = gest.MAXC;
            if isnan(maxc_x)
                maxc_x = gest.PVEL;
            end

            maxc_trace = struct(...
                'x', maxc_x / video_frameRate, ...
                'y', s(maxc_x), ...
                'mode', 'markers+text', ...
                'marker', struct(...
                    'color', '#000000', ...
                    'symbol', 'hexagon' ...
                ), ...
                'text', char(label), ...%char(gest.articulator), ...
                'textposition', 'top center', ...
                'yaxis', ['y' num2str(nYAxes)], ...
                'showlegend', false, ...
                'type', 'scatter' ...
            );

%             if iArticulator == length(articulators) && iGest == 1
%                 maxc_trace.name = 'Label';
%                 maxc_trace.showlegend = true;
%             end
        end
        
        function [transcription_trace] = create_transcription_trace(obj, textgrid_label_times, textgrid_labels, nYAxes)
            % 'x', textgrid_label_time_samples, ...
            % 'y', ones(size(textgrid_label_time_samples)) * -0.02, ...
            transcription_trace = struct(...
                'x', textgrid_label_times, ...
                'y', ones(size(textgrid_label_times)) * -0.02, ...
                'type', 'scatter', ...
                'text', { cellstr(textgrid_labels) }, ... % { {'B', 't', 'PF', 't' ...} }
                'yaxis', ['y' num2str(nYAxes)], ...
                'textposition', 'bottom center', ...
                'textfont', struct('size', 16), ...
                'showlegend', false, ...
                'mode', 'text' ...
            );
        end
        
        function [gest_trace] = create_gest_trace(obj, gest, video_frameRate, maxy, color_as_rgb, nYAxes)
        %     gest_x = [gests.GONS(iGest), gests.GOFFS(iGest)] / frameRate;

            % Gesture isn't split if you can find a GOFFS
            if ~isnan(gest.GOFFS)
                gest_x = [gest.GONS, gest.GOFFS];
            else
                % Gesture is split. If there's a MAXC, use it...
                if ~isnan(gest.NOFFS)
                    gest_x = [gest.GONS, gest.NOFFS];

                % ...otherwise, just use GONS to NONS
                else
                    gest_x = [gest.GONS, gest.NONS];
                end
            end
            gest_x = gest_x / video_frameRate;

%             gests(:, {'GONS', 'PVEL', 'NONS', 'MAXC', 'NOFFS', 'PVEL2', 'GOFFS'});

%             fillcolor = 'rgba(192, 192, 192, 0.3)'; % light gray gesture box
            fillcolor = strrep(color_as_rgb, '1.0', '0.3'); % color-matched gesture box

            gest_trace = struct(...
                'x', gest_x, ...
                'y', [maxy*[1 1]], ...
                'fill', 'tozeroy', ...
                'fillcolor', fillcolor, ...
                'mode', 'none', ...
                'yaxis', ['y' num2str(nYAxes)], ...
                'showlegend', false, ...
                'type', 'scatter' ...
            );

%             if iArticulator == 1 && iGest == 1
%                 gest_trace.showlegend = true;
%                 gest_trace.name = 'Gesture duration';
%             end
        end
        
        function [nYAxes, plotly_data, layout] = addMeterAxis(obj, nYAxes, plotly_data, layout, meter_labels, textgrid_label_times, textgrid_labels, textgrid_label_time_samples)
            nYAxes = nYAxes + 1;
        
            [meter_trace, layout] = create_meter_trace(obj, layout, meter_labels, textgrid_label_times, textgrid_labels, nYAxes);
        
            transcription_trace.yaxis = ['y' num2str(nYAxes)];
            transcription_trace.y = ones(size(textgrid_label_time_samples)) * -0.1;
            plotly_data = [plotly_data(:)', {meter_trace}, {transcription_trace}];
        
            if nYAxes == 1
                YAxis = 'yaxis';
            else
                YAxis = ['yaxis' num2str(nYAxes)];
            end
            layout.(YAxis).title.text = 'METER';
            layout.(YAxis).title.font.size = 20;
            layout.(YAxis).range = [-1, max(meter_trace.y)+1];
        %         layout.(YAxis).showgrid = false;
        end
        
        function [meter_trace, layout] = create_meter_trace(obj, layout, meter_labels, textgrid_label_times, textgrid_labels, nYAxes)
            meterx = [];
            metery = [];
            for iMeterLabel = 1:length(meter_labels)
                switch meter_labels(iMeterLabel)
                    case "1"
                        numXs = 5;
                    case "3"
                        numXs = 4;
                    case {"2", "4"}
                        numXs = 3;
                    case {"1.5", "2.5", "3.5", "4.5"}
                        numXs = 2;
                    otherwise
                        numXs = 1;
                end
                % newx = repmat(textgrid_label_time_samples(iMeterLabel), numXs, 1);
                newx = repmat(textgrid_label_times(iMeterLabel), numXs, 1);
                newy = (1:numXs)';
                meterx = [meterx; newx];
                metery = [metery; newy];
            end

            meter_trace = struct(...
                'x', meterx, ...
                'y', metery, ...
                'text', { cellstr(textgrid_labels) }, ... % { {'B', 't', 'PF', 't' ...} }
                'yaxis', ['y' num2str(nYAxes)], ...
                'showlegend', false, ...
                'marker', struct(...
                    'color', '#000000', ...
                    'size', 8, ...
                    'symbol', 'x' ...
                ), ...
                'mode', 'markers', ...
                'type', 'scatter' ...
            );
        end
        
        function layout = formatAxes(obj, nYAxes, layout)
            padding = 0.02;% * (nYAxes - 1);
            w = (1 - (padding * (nYAxes - 1))) / nYAxes;
            start_loc = 0;
            for iAxis = 1:nYAxes
                if iAxis == 1
                    YAxis = 'yaxis';
                else
                    YAxis = ['yaxis' num2str(iAxis)];
                end

                layout.(YAxis).domain = [start_loc, start_loc + w];
                start_loc = start_loc + w + padding;

                layout.(YAxis).showticklabels = false;
            end
        end
        
        function [] = plotlyOffline(obj, plotly_data, layout)
            p = plotlyfig; % initalize an empty figure object
            p.data = plotly_data;
            p.layout = layout;
            p.layout.width = 1000;
            p.layout.height = 700;

            p.PlotOptions.FileName = 'basic-offline';
            p.PlotOptions.FileOpt = 'overwrite';

            % Create a standalone HTML file
            html_file = plotlyoffline(p);
            % Add this to the top of your output file:
            % <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>

    %         web(html_file, '-browser');
        end
        
        function color_as_rgb = color_percent_to_rgb(obj, color_as_percent)
            color_as_percent = color_as_percent * 255;
            color_as_rgb = ['rgba(' num2str(color_as_percent(1)) ', ' num2str(color_as_percent(2)) ', ' num2str(color_as_percent(3)) ', 1.0)'];
        end
        
        function cleanup(obj)
            % later
        end
    end
end


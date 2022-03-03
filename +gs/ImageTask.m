classdef ImageTask
    
    methods
        function gif(obj, basename, img_out_folder, phone_ID, phone_label, video, start_frame, end_frame)
            allFrames = start_frame:end_frame;
            
            fig = figure;
            fr = rescale(reshape(video.matrix(allFrames(1),:), video.width, video.height));
            imagesc(fr);
            axis image;
            colormap gray;
            set(gca,'nextplot','replacechildren','visible','off');
            
            delayTime = 1 / video.frameRate;
            savename = fullfile(img_out_folder, char(basename), [char(basename) '_' num2str(phone_ID) '_' char(phone_label) '.gif']);
            disp(savename);
            newdir = fullfile(img_out_folder, char(basename));
            
            if ~exist(newdir, 'dir')
                mkdir(newdir);
            end
            
            for iFrame = 1:length(allFrames)
                
                fr = rescale(reshape(video.matrix(allFrames(iFrame),:), video.width, video.height));
                
                imagesc(fr);
                axis image;
                colormap gray;
                drawnow
                
                [A, map] = rgb2ind(frame2im(getframe(gca)), 256);
                
                if iFrame == 1
                    imwrite(A, map, savename, 'gif', 'DelayTime', delayTime, 'LoopCount', inf);
                else
                    imwrite(A, map, savename, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
                end

%                 imwrite(resize(this.image, 2, 'cubic'), fullpath);
            end
            close(fig);
        end
    end
    
end
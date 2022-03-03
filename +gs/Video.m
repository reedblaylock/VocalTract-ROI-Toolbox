classdef Video
    properties
        filename
        width
        height
        nFrames
        frameRate
        matrix
    end
    
    methods
        function obj = Video(fname_avi)
            vr = VideoReader(fname_avi);
            vidFrames = read(vr);

            % Convert VideoReader output to something usable
            % run backwards so the loop goes faster?
            % https://www.mathworks.com/matlabcentral/answers/48807-how-preallocate-structure-for-better-memory
            for k = vr.NumFrames:-1:1
                mov(k).cdata = vidFrames(:,:,:,k); 
            %     mov(k).colormap = []; 
            end

            % Get movie information
            vec_length = vr.Height * vr.Width;

            % Reshape matrix
            M = zeros(vr.NumFrames, vec_length);
            for itor = 1:vr.NumFrames
                M(itor,:) = reshape(double(mov(itor).cdata(:,:,1)), 1, vec_length);
            end

            % Normalize matrix
            M = M./repmat(mean(M,2), 1, size(M,2));

            obj.filename = fname_avi;
            obj.width = vr.Width;
            obj.height = vr.Height;
            obj.nFrames = vr.NumFrames;
            obj.frameRate = vr.FrameRate;
            obj.matrix = M;
        end
    end
end
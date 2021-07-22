classdef DynamicProgrammer < handle
	%	DynamicProgrammer Finds the brightest path between two points in an image using a dynamic programming algorithm.
	% 	
	%	DynamicProgrammer Methods:
	%		DynamicProgrammer - Constructor method.
	%		setImage - Sets the value for the image property.
	%		findPath - Finds the brightest path between two points in an image.
	%
	%	See also VocalTract
	
	%	Reed Blaylock July 16, 2014
    
    properties
        image
    end
	
	methods
		function [this] = DynamicProgrammer(image)
			%	DynamicProgrammer	Constructor method for the DynamicProgrammer class.
			%		this = DynamicProgrammer()				Returns a new DynamicProgrammer thisect. An image must be set using the setImage() method before using this class.
			%		this = DynamicProgrammer(image)			Returns a new DynamicProgrammer thisect with a user-defined image. NOTE: This functionality is currently unstable. Use the empty constructor and a call to setImage() instead of passing the image into the constructor.
			%
			%	Input arguments:
			%		image - (optional) A r x c matrix of pixel intensity values.
			%
			%	Output arguments:
			%		this - A DynamicProgrammer thisect.
			%
			%	Example: Invoking the constructor
			%		this = DynamicProgrammer();
			%
			%	See also findPath, setImage, VocalTract
			
			this.image = image;
		end

		
		function [path] = findPath(this, image, startPoint, endPoint)
			%	findPath	Find the brightest path between three points of an image.
			%		this.findPath(points)				Returns a list of x/y coordinates corresponding to the brightest path through an image.
			%
			%	Input arguments:
			%		this - A DynamicProgrammer thisect.
			%		points - An Nx2 matrix of x/y coordinates representing the brightest path through a set of points.
			%
			%	Example: Finding the brightest path
			%		this = DynamicProgrammer();
			%		this.setImage(new_image);
			%		this.findPath(points);
			%
			%	See also DynamicProgrammer, setImage
            
%             B		% A rxc matrix whose rows and columns correspond to x and y coordinates in an image. The values of B are 0.0, or the cumulative brightness from a given coordinate to some endpoint.
%             P		% A rx2x(r*c) matrix which stores the coordinaes of the brightest path from a given coordinate (top of its column in the z-dimension) to an endpoint.
%             image	% A rxc matrix (treated here as an image) whose pixel intensity values will be used to establish the brightest path.
			
			[P, B] = this.iterativeDynamicProgramming(image, startPoint, endPoint);
			path = this.filterPath(P);
		end

		function [P, B] = reset(this, image)
			%	Resets the B and P properties. Useful when beginning a new portion of the dynamic programming algorithm.
			[r, c] = size(image);
			B = zeros(r,c);
			P = zeros(r,2,r*c);
		end
		
        function [path] = filterPath(this, P)
            %	Finds and returns the best path from the P property

            Pzero = find(P(1,1,:) == 0);
            bestPath = Pzero(1)-1;
            unfilteredPath = P(:,:,bestPath);
            path = unfilteredPath(any(unfilteredPath,2),:);
        end
		
		function [P, B] = iterativeDynamicProgramming(this, image, startPoint, endPoint)
			%	The dynamic programming algorithm (iterative)
            
            [P, B] = this.reset(image);
			
			startX = startPoint(1,1);
			startY = startPoint(1,2);
			endX = endPoint(1,1);
			endY = endPoint(1,2);
			
            tx = endX - startX;
            ty = endY - startY;

			j = 0;
			B(endX, endY) = image(endY, endX);
			P(1,1,1) = endX;
			P(1,2,1) = endY;
			states = endPoint;

			while ~isempty(states)
				newStates = [];
				for i = 1:size(states, 1)
					currentPoint = states(i,:);
					currentX = currentPoint(1,1);
					currentY = currentPoint(1,2);
					
			% 		Get the set of points that are reasonable continuations
			% 		from this one
                    adjacentPoints = [currentX+1, currentY-1; currentX+1, currentY; currentX+1, currentY+1; currentX, currentY+1; currentX-1, currentY+1];
                    adjacentBrightnesses = [B(currentX+1, currentY-1); B(currentX+1, currentY); B(currentX+1, currentY+1); B(currentX, currentY+1); B(currentX-1, currentY+1)];

            % % 	[x-1, y+1] downleft
                    x = currentX - 1;
                    y = currentY + 1;
                    if y <= startY+(tx-j) && y >= startY-(tx-j)
                        newStates = [newStates; x, y];
                    end

            % % 	[x-1, y] left
                    x = currentX - 1;
                    y = currentY;
                    if y <= startY+(tx-j) && y >= startY-(tx-j)
                        newStates = [newStates; x, y];
                    end

            % % 	[x-1, y-1] upleft
                    x = currentX - 1;
                    y = currentY - 1;
                    if y <= startY+(tx-j) && y >= startY-(tx-j)
                        newStates = [newStates; x, y];
                    end

            % % 	[x+1, y-1] upright
                    x = currentX + 1;
                    y = currentY - 1;
                    if x <= startX+(ty-j) && x >= startX-(ty-j)
                        newStates = [newStates; x, y];
                    end

            % % 	[x, y-1] up
                    x = currentX;
                    y = currentY - 1;
                    if x <= startX+(ty-j) && x >= startX-(ty-j)
                        newStates = [newStates; x, y];
                    end
					
					if isequal(currentPoint, endPoint) % Values for the initial case have already been supplied, so skip this iteration and move on to the next stage
						continue;
					end
					
					[previous_brightness, index] = max(adjacentBrightnesses);

			% 		The best path from this point has been found.
					brightness = image(currentY, currentX) + previous_brightness;
					B(currentX, currentY) = brightness;

					% Add this point to the potential path
					adjacentX = adjacentPoints(index,1);
					adjacentY = adjacentPoints(index,2);

					p = find(P(1,1,:) == adjacentX & P(1,2,:) == adjacentY);
					zIndex = p(1);
					pathSegment = P(:,:,zIndex);

					newPath = [currentPoint; pathSegment];
					trimmedPath = newPath(1:(size(image,1)),:);

					rowToReplace = find(P(1,1,:) == 0);
					rowToReplace = rowToReplace(1);
					P(:,:,rowToReplace) = trimmedPath;
			
				end
				states = unique(newStates, 'rows');
				j = j + 1;
			end
        end
    end
	
end
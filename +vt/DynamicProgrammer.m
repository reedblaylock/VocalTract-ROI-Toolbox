classdef DynamicProgrammer < vt.Root & vt.Action.Dispatcher
	%	DynamicProgrammer Finds the brightest path between two points in an image using a dynamic programming algorithm.
	% 	
	%	DynamicProgrammer Methods:
	%		DynamicProgrammer - Constructor method.
	%		setImage - Sets the value for the image property.
	%		findPath - Finds the brightest path between two points in an image.
	%
	%	See also VocalTract
	
	%	Reed Blaylock July 16, 2014
	
	properties (Access = private)
		B		% A rxc matrix whose rows and columns correspond to x and y coordinates in an image. The values of B are 0.0, or the cumulative brightness from a given coordinate to some endpoint.
		P		% A rx2x(r*c) matrix which stores the coordinaes of the brightest path from a given coordinate (top of its column in the z-dimension) to an endpoint.
		image	% A rxc matrix (treated here as an image) whose pixel intensity values will be used to establish the brightest path.
		
		actionType = @vt.Action.SetMidline
	end
	
	methods
		function [obj] = DynamicProgrammer(image)
			%	DynamicProgrammer	Constructor method for the DynamicProgrammer class.
			%		obj = DynamicProgrammer()				Returns a new DynamicProgrammer object. An image must be set using the setImage() method before using this class.
			%		obj = DynamicProgrammer(image)			Returns a new DynamicProgrammer object with a user-defined image. NOTE: This functionality is currently unstable. Use the empty constructor and a call to setImage() instead of passing the image into the constructor.
			%
			%	Input arguments:
			%		image - (optional) A r x c matrix of pixel intensity values.
			%
			%	Output arguments:
			%		obj - A DynamicProgrammer object.
			%
			%	Example: Invoking the constructor
			%		obj = DynamicProgrammer();
			%
			%	See also findPath, setImage, VocalTract
			
			p = vt.InputParser;
			p.addRequired('image', @isnumeric)
			parse(p, image);
			
			this.setImage(image);
% 			this.reset();
		end
		
		function [] = setImage(this, image)
			%	setImage	Sets the image for this DynamicProgrammer.
			%		this.setImage(image)				Assigns the submitted image to the image property of this DynamicProgrammer.
			%
			%	Input arguments:
			%		obj - A DynamicProgrammer object.
			%		image - A r x c matrix of pixel intensity values.
			%
			%	Example: Setting the image
			%		obj = DynamicProgrammer();
			%		this.setImage(new_image);
			%
			%	See also DynamicProgrammer
			
			this.image = image;
			this.reset();
		end
		
		function [wholePath] = findPath(this, points)
			%	findPath	Find the brightest path between three points of an image.
			%		this.findPath(points)				Returns a list of x/y coordinates corresponding to the brightest path through an image.
			%
			%	Input arguments:
			%		obj - A DynamicProgrammer object.
			%		points - An Nx2 matrix of x/y coordinates representing the brightest path through a set of points.
			%
			%	Example: Finding the brightest path
			%		obj = DynamicProgrammer();
			%		this.setImage(new_image);
			%		this.findPath(points);
			%
			%	See also DynamicProgrammer, setImage
			
			startPoint = points(1,:);
			endPoint = points(2,:);
			V(this, startPoint, endPoint, 'right');
			
			path1 = this.filterPath();
			
			this.reset();
			
			startPoint = points(2,:);
			endPoint = points(3,:);
			V(this, startPoint, endPoint, 'down');
			
			path2 = this.filterPath();
			
			this.reset();
			
			s1 = size(path1,1);
			s2 = size(path2,1);
			m1 = floor(s1/5);
			m2 = floor(s2/5);
			x1 = path1(end-m1, 1);
			y1 = path1(end-m1, 2);
			x2 = path2(m2,1);
			y2 = path2(m2,2);

			this.V([x1, y1], [x2, y2], 'downright');

			path3 = this.filterPath();

			topPath = path1(1:end-m1,:);
			bottomPath = path2(m2+1:end,:);

			wholePath = [topPath; path3; bottomPath];
			
			% The path has been calculated, so send it to vt.Reducer
			this.action.dispatch(wholePath);
		end
	end
	
	methods (Access = private)
		function [] = reset(this)
			%	Resets the B and P properties. Useful when beginning a new portion of the dynamic programming algorithm.
			[r, c] = size(this.image);
			this.B = zeros(r,c);
			this.P = zeros(r,2,r*c);
		end
		
		function [path] = filterPath(this)
			%	Finds and returns the best path from the P property
			
			Pzero = find(this.P(1,1,:) == 0);
			bestPath = Pzero(1)-1;
			unfilteredPath = this.P(:,:,bestPath);
			path = unfilteredPath(any(unfilteredPath,2),:);
		end
		
		function [] = V(this, startPoint, endPoint, direction)
			%	The dynamic programming algorithm (iterative)
			
			startX = startPoint(1,1);
			startY = startPoint(1,2);
			endX = endPoint(1,1);
			endY = endPoint(1,2);
			
			switch direction
				case 'right'
					t = endX - startX;
				case 'down'
					t = endY - startY;
				case 'downright'
				otherwise
			end
			j = 0;
			this.B(endX, endY) = this.image(endY, endX);
			this.P(1,1,1) = endX;
			this.P(1,2,1) = endY;
			states = endPoint;

			while ~isempty(states)
				newStates = [];
				for i = 1:size(states, 1)
					currentPoint = states(i,:);
					currentX = currentPoint(1,1);
					currentY = currentPoint(1,2);
					
			% 		Get the set of points that are reasonable continuations
			% 		from this one
					switch direction
						case 'right'
							adjacentPoints = [currentX+1, currentY-1; currentX+1, currentY; currentX+1, currentY+1];
							adjacentBrightnesses = [this.B(currentX+1, currentY-1); this.B(currentX+1, currentY); this.B(currentX+1, currentY+1)];
							
					% % 	[x-1, y+1] downleft
							x = currentX - 1;
							y = currentY + 1;
							if y <= startY+(t-j) && y >= startY-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x-1, y] left
							x = currentX - 1;
							y = currentY;
							if y <= startY+(t-j) && y >= startY-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x-1, y-1] upleft
							x = currentX - 1;
							y = currentY - 1;
							if y <= startY+(t-j) && y >= startY-(t-j)
								newStates = [newStates; x, y];
							end
						case 'down'
							adjacentPoints = [currentX+1, currentY+1; currentX, currentY+1; currentX-1, currentY+1];
							adjacentBrightnesses = [this.B(currentX+1, currentY+1); this.B(currentX, currentY+1); this.B(currentX-1, currentY+1)];
							
					% % 	[x+1, y-1] upright
							x = currentX + 1;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x, y-1] up
							x = currentX;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x-1, y-1] upleft
							x = currentX - 1;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end
						case 'downright'
							adjacentPoints = [currentX+1, currentY+1; currentX, currentY+1; currentX+1, currentY];
							adjacentBrightnesses = [this.B(currentX+1, currentY+1); this.B(currentX, currentY+1); this.B(currentX+1, currentY)];
							
					% % 	[x-1, y] left
							x = currentX - 1;
							y = currentY;
							if x <= endX && x >= startX && y <= endY && y >= startY
								newStates = [newStates; x, y];
							end

					% % 	[x, y-1] up
							x = currentX;
							y = currentY - 1;
							if x <= endX && x >= startX && y <= endY && y >= startY
								newStates = [newStates; x, y];
							end

					% % 	[x-1, y-1] upleft
							x = currentX - 1;
							y = currentY - 1;
							if x <= endX && x >= startX && y <= endY && y >= startY
								newStates = [newStates; x, y];
							end
						otherwise
					end
					
					if isequal(currentPoint, endPoint) % Values for the initial case have already been supplied, so skip this iteration and move on to the next stage
						continue;
					end
					
					[previous_brightness, index] = max(adjacentBrightnesses);

			% 		The best path from this point has been found.
					brightness = this.image(currentY, currentX) + previous_brightness;
					this.B(currentX, currentY) = brightness;

					% Add this point to the potential path
					adjacentX = adjacentPoints(index,1);
					adjacentY = adjacentPoints(index,2);

					p = find(this.P(1,1,:) == adjacentX & this.P(1,2,:) == adjacentY);
					zIndex = p(1);
					pathSegment = this.P(:,:,zIndex);

					newPath = [currentPoint; pathSegment];
					trimmedPath = newPath(1:(size(this.image,1)),:);

					rowToReplace = find(this.P(1,1,:) == 0);
					rowToReplace = rowToReplace(1);
					this.P(:,:,rowToReplace) = trimmedPath;
			
				end
				states = unique(newStates, 'rows');
				j = j + 1;
			end
		end
	end
	
end
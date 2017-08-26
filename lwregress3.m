function [T, W] = lwregress3(X,Y,D,h)
%
%   FUNCTION:
%   Locally-weighted regression
%
%   USAGE:
%   [T W] = lwregress(X,Y,D,h,pl);
%
%   INPUTS:
%   X (Nx1 float):	input domain
%   Y (Nx1 float):	data points sampled at values in X
%   D (Mx1 float):	data points over which to regress function
%   pl (int):       verbosity:	0: work silently
%                               1: plot original & interpolated functions
%                               2: plot also regression weights
%
%	OUTPUTS
%	T: regression points corresponding to the input data points
%	W: regression weights corresponding to the input data points
%
%   EXAMPLE:
%   dat	= dlmread('regression.data');
%   X	= dat(:,1);
%   Y	= dat(:,2);
%   D	= linspace(min(X),max(X),200)';
%   [T W] = lwregress( X,Y,D,0.5,2 );
%
%   AUTHOR:
%   Adam Lammert (2010)
%   modified by M.Proctor (2011) for use in <find_consonant_gests.m>
%	modified by Reed Blaylock (2014) for faster ROI timeseries smoothing

    % constants
    c = 0.0001;

    % initialize
	height  = size(D,1);
    X_aug	= [X ones(size(X,1),1)];	%augmented data
    T       = zeros(height,1);	    %regression points
    W       = zeros(height,2);      %regression coeffs
	h       = 1/(2*(h^2));
	id      = eye(2);

    %Primary Loop
    for i = 1:height
        %Kernel Distances
        diff = D(i) - X;
		w2 = exp(-1*diff.*h.*diff);
		w2(w2<0.0001) = 0.00001;
		K = diag(w2);

        %Ridge Regression
        W(i,:) = (X_aug'*K*X_aug + c*id)\(X_aug'*K*Y);

        %Evaluate Regression Line
        T(i) = W(i,1)*D(i) + W(i,2);
    end
end

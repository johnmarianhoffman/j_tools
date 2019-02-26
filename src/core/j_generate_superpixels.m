function [sp_img,sp_outline,sp,n] = j_generate_superpixels(img,n_superpixels_requested)
% Wrapper for MATLAB's example (just returns everything rather than
% making the user do it)
%
% Inputs:
%   img                     - image matrix
%   n_superpixels_requested - number of superpixels requested
%
% Outputs:
%   sp_img    - image with each super pixel set to the mean color value of the original image
%   sp_output - original image with superpixel boundary mask overlay
%   sp        - superpixel label output from MATLAB's "superpixels" function
%   n         - actual number of superpixels computed
%

A = img;

[L,N] = superpixels(A,n_superpixels_requested,'compactness',.2);

BW = boundarymask(L);
sp_outline = imoverlay(A,BW,'black');

% Set color of each pixel in output image to the mean RGB color of the
% superpixel region.
outputImage = zeros(size(A),'like',A);
idx = label2idx(L);
numRows = size(A,1);
numCols = size(A,2);
for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    outputImage(redIdx) = mean(A(redIdx));
    outputImage(greenIdx) = mean(A(greenIdx));
    outputImage(blueIdx) = mean(A(blueIdx));
end

sp_img = outputImage;
sp = L;
n = N;

end
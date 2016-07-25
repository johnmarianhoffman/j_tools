function [ output_args ] = show( image,varargin)
%SHOW Summary of this function goes here
%   Detailed explanation goes here

if isempty(varargin)
    figure;
end

if ~isempty(varargin)
    if nargin==2
        figure;
        wl=varargin{1};
        max=wl(2)+wl(1)/2;
        min=wl(2)-wl(1)/2;
        imshow(image,[min max]);
    elseif nargin==3
        wl=varargin{1};
        max=wl(2)+wl(1)/2;
        min=wl(2)-wl(1)/2;
        imshow(image,[min max]);
    end
else
    imshow(image,[]);
end

end


function [ stack ] = r(varargin)
%R Summary of this function goes here
%   Detailed explanation goes here
if isempty(varargin)
    stack=read_disp_recon;
else
    stack=read_disp_recon(1);
end
end


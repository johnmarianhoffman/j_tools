function [ TF ] = isequal_or( A, B, varargin )
% ISEQUAL_OR Tests for equality between two or more inputs
%   TF=ISEQUAL_OR(A,B) Tests if A is equal to B.  Uses builtin matlab
%   function isequal so inputs can be of different types. When called with
%   only two inputs, function is equivalent to ISEQUAL.
%
%   TF=ISEQUAL_OR(A,B,C) Tests for equality between A and other input
%   variables.  Function will return true if A is equal to B or C (or
%   both).  Function will only return "false" if A does not equal B or C.  
%
%   TF=ISEQUAL_OR(A,N1,N2,...,NN) Will test if A equals any of the other
%   inputs.  
%
%   Example:
%
%       >> A='string1';
%       >> B='string2';
%       >> C='string3';
%       >> D='string4';
%       >> N=A;
%
%       >> isequal_or(A,B,C,D)
%
%           ans = 
%
%               0
%
%       >> isequal_or(A,B,C,D,N)
%
%           ans = 
%
%               1
%
%   See also: ISEQUAL
%
% Last Modified by John Hoffman on 2015-03-23 at 12:16 PM

if nargin<2
    error('OIQ_Toolbox:utilities:isequal_or','Not enough inputs');
end

if isequal(A,B)
    TF=true;
    return;
end

for i=1:numel(varargin)
    if isequal(A,varargin{i})
        TF=true;
        return;
    end
end

TF=false;
end


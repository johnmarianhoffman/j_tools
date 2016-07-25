function [oiqErr,full_path]=j_UIGetDir(start_path,title)
% OIQFUNCTION Wrapper for MATLAB's UIGETDIR function to match other oiq functions 
% 	[OIQERR,O]=OIQFUNCTION(I) In depth description and help goes here
try
    oiqErr=1;
    full_path=[];
    
    p=uigetdir(start_path,title);
    if ~isequal(0,p)
        full_path=p;
        oiqErr=0;
    end
catch ME
	oiqErr=99;
	oiqHandleErrors(oiqErr,ME);
end
end

function [full_path]=j_UIGetFile(start_path,filter_spec,title)
% OIQFUNCTION Replacement for MATLAB's disappointing uigetfile function 
% 	[OIQERR,O]=OIQFUNCTION(I) In depth description and help goes here

    if nargin==0
        filter_spec={'*.*'};
        start_path=pwd;
        title='findafile';
    end
    
    full_path=[];
    if isempty(start_path)
        start_path=pwd;
    end

    curr_loc=pwd;
	cd(start_path);
    [f,p]=uigetfile(filter_spec,title);
    if ~isequal_or(0,f,p)
        full_path=fullfile(p,f);
        oiqErr=0;
    end
    cd(curr_loc);
end

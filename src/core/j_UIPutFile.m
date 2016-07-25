function [oiqErr,full_path]=j_UIPutFile(start_path,filter_spec,title)
% OIQFUNCTION Replacement for MATLAB's disappointing uigetfile function 
% 	[OIQERR,O]=OIQFUNCTION(I) In depth description and help goes here
    oiqErr=1;
    full_path=[];
    if isempty(start_path)
        start_path=pwd;
    end
    
    curr_loc=pwd;
    cd(start_path);
    [f,p]=uiputfile(filter_spec,title);
    if ~isequal_or(0,f,p)
        full_path=fullfile(p,f);
        oiqErr=0;
    end
    cd(curr_loc);
end

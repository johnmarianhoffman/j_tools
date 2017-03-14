function stack=read_disp_recon_128(varargin)

    dim=128;
    
    if nargin==1&&exist(varargin{1},'file');
        fp=varargin{1};
    elseif nargin==1&&isequal(varargin{1},'get')
        try
            prev_uidir=evalin('base','prev_uidir');
        catch
            prev_uidir=pwd;
        end
        [fp]=j_UIGetFile(prev_uidir,{'*.*'},'Grab image stack file');
        [p,f,e]=fileparts(fp);
        assignin('base','prev_uidir',p);        
        file_path=fullfile(p,f);
    end
    fid=fopen(fp,'r');
    stack=fread(fid,'float32');
    fclose(fid);

    stack=reshape(stack,[dim,dim,numel(stack)/(dim^2)]);

end

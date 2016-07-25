function [ varargout]=write_read_raw_binary( filename,op,varargin )
switch op
    case 'write'
        fid=fopen(filename,'w','l');
        fwrite(fid,permute(varargin{1},[2 1 3]),'float',0,'l');
        fclose(fid);
    case 'read'
        fid=fopen(filename,'r','l');
        if nargin==4
            endianness=varargin{2};
        else
            endianness='l';
        end
        
        if ~isempty(varargin)
            varargout{1}=fread(fid,varargin{1},endianness);
        else
            varargout{1}=fread(fid,'float',endianness);
        end
        fclose(fid);
end
end


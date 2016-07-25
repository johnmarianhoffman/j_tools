function [ varargout]=write_read_raw_binary_double( filename,op,varargin )
switch op
    case 'write'
        fid=fopen(filename,'w','l');
        fwrite(fid,permute(varargin{1},[2 1 3]),'double',0,'l');
        fclose(fid);
    case 'read'
        fid=fopen(filename,'r','l');
        varargout{1}=fread(fid,'double','l');
        fclose(fid);
end
end


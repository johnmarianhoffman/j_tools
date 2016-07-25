function data=j_bin(f,varargin)

if nargin<1||isequal(f,'get')
    f=j_UIGetFile(pwd,{*.*},'Get binary file');
end

if ~isempty(varargin)
    op='read';
else
    op=varargin{1};
end

switch op
  case 'read'
    fid=fopen(filename,'r','l');
    if nargin==4
        endianness=varargin{2};
    else
        endianness='l';
    end

    data=fread(fid,'float',endianness);
    
    fclose(fid);
  case 'write'
end

end


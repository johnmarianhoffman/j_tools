function data=j_bin_float(f,varargin)
% Assumes little endian
endianness='l';

if nargin<1||isequal(f,'get')
    f=j_UIGetFile(pwd,{'*.*'},'Get binary file');
end

if isempty(varargin)
    op='read';
else
    op=varargin{1};
end

fid=fopen(f,lower(op(1)),endianness);

switch op(1)
  case 'r'
    data=fread(fid,'float',endianness);
  case 'w'
    fwrite(fid,permute(varargin{2},[1 2 3]),'float',0,endianness);
end

fclose(fid);
end


function data=j_bin_double(f,varargin)
% Assumes little endian

if nargin<1||isequal(f,'get')
    f=j_UIGetFile(pwd,{'*.*'},'Get binary file');
end

if isempty(varargin)
    op='read';
else
    op=varargin{1};
end

fid=fopen(f,lower(op(1)),'l');

switch op(1)
  case 'r'
    data=fread(fid,'double','l');
  case 'w'
    fwrite(fid,permute(varargin{1},[2 1 3]),'double',0,'l');
end

fclose(fid);
end


function tf=isdicom(file_path)

fid=fopen(file_path,'r');
fseek(fid,128,'bof');
raw=fread(fid,4,'schar');

word=char(raw');
tf=isequal('dicm',lower(word));

end
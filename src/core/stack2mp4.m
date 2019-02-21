function stack2mp4(stack,scale,output_filepath)
v=VideoWriter(output_filepath,'MPEG-4');
open(v);
a=stack;

if isempty(scale)
    scale=[min(a(:)),max(a(:))];    
end

b=gray2ind(mat2gray(a,scale),255);
for i=1:size(a,3)    
    
    fprintf('Writing frame %d/%d\n',i,size(a,3));
    
    % Create RGB matrix
    f=repmat(b(:,:,i),[1 1 3]);
    writeVideo(v,f);
end

close(v);
clear v

end
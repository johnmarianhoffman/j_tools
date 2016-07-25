function wed=j_wed(stack,a_pix,varargin)
% J_WED Calculate water equivalent diameter for a stack of images

p=inputParser;
p.addRequired('stack')
p.addRequired('a_pix') % area of a pixel
p.addOptional('roi',[])

parse(p,stack,a_pix,varargin{:})
stack=p.Results.stack;
a_pix=p.Results.a_pix;
roi=p.Results.roi;

n_slices=size(stack,3);

wed=zeros(1,n_slices);

if ~isempty(roi)
    m=createMask(roi);

    masked_stack=zeros(sum(m(:)),n_slices);
    for i=1:n_slices
        curr_slice=stack(:,:,i);
        masked_stack(:,i)=curr_slice(m);
    end

    stack=masked_stack;
else
    reshape_stack=zeros(numel(stack(:,:,1)),n_slices);
    for i=1:n_slices
        curr_slice=stack(:,:,i);
        reshape_stack(:,i)=curr_slice(:);
    end

    stack=reshape_stack;
end

a_roi=numel(stack(:,1))*a_pix;

for i=1:n_slices
    wed(i)=real(2*sqrt(((1/1000)*mean(stack(:,i))+1)*a_roi/pi));
    %fprintf(1,'%.2f\n',wed(i))
end 

end
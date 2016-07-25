function a_stack=average_slices(stack,n)

n_out=floor(size(stack,3)/n);

a_stack=zeros(size(stack,1),size(stack,2),n_out);

for i=1:n_out
    a_stack(:,:,i)=mean(stack(:,:,((i-1)*n+1):n*i),3);   
end
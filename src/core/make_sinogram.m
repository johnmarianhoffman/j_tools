function [ sino_stack,b ] = make_sinogram( data, n_rows, n_channels,oversampled )
%MAKE_SINOGRAM Summary of this function goes here
%   Detailed explanation goes here

if oversampled
    
    n_proj=numel(data)/(n_rows*2*n_channels);
    
    b=reshape(data,[n_channels*2 n_rows  n_proj]);
    
    sino_stack=zeros(2*n_channels,n_proj,n_rows);
    
    for i=1:n_rows
        sino_stack(:,:,i)=squeeze(b(:,i,:));
    end
else
    n_proj=numel(data)/(n_rows*n_channels);
    
    b=reshape(data,[ n_channels n_rows n_proj]);
    
    sino_stack=zeros(n_channels,n_proj,n_rows);
    
    for i=1:n_rows
        sino_stack(:,:,i)=squeeze(b(:,i,:));
    end
end
end


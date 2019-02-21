function [h,h_f]=j_ramp_filter(filter_size)
n = filter_size;
nn=[-n/2:(n/2-1)];
h=zeros(size(nn),'single');
h(n/2+1)=  1/4;
odd = mod(nn,2)==1;
h(odd) = -1./(pi*nn(odd)).^2;

h_f = abs(fft(h));
end
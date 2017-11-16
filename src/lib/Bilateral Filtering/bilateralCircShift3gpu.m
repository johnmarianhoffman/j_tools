function O=bilateralCircShift3gpu(A,w,sigma_d,sigma_r)

O=zeros(size(A));
N=zeros(size(A));
I_s=zeros(size(A));

d_A=gpuArray(A);
d_O=gpuArray(O);
d_N=gpuArray(N);

for dx=-w:w
    for dy=-w:w
        for dz=-w:w
            I_s=circshift(d_A,[dx dy dz]);
            delta=d_A-I_s;

            wt1=exp(-(dx^2+dy^2+dz^2)/(2*sigma_d^2));
            wt2=exp(-delta.^2/(2*sigma_r^2));
            weight=wt1.*wt2;

            d_N=d_N+weight;
            d_O=d_O+weight.*I_s;
        end
    end
end

d_O=d_O./d_N;

O=gather(d_O);

end

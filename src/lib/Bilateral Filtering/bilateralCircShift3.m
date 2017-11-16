function O=bilateralCircShift3(A,w,sigma_d,sigma_r)

O=zeros(size(A));
N=zeros(size(A));

%d_A=gpuArray(A)
%d_O=gpuArray(O)
%d_N=gpuArray(N)

for dx=-w:w
    for dy=-w:w
        for dz=-w:w
            I_s=circshift(A,[dx dy dz]);
            delta=A-I_s;

            wt1=exp(-(dx^2+dy^2+dz^2)/(2*sigma_d^2));
            wt2=exp(-delta.^2/(2*sigma_r^2));
            weight=wt1*wt2;

            N=N+weight;
            O=O+weight.*I_s;
        end
    end
end

O=O./N;

end

function out = j_fftshift(f)
    
    N = numel(f);
    out = zeros(size(f));
    for (i=N/2:N-1)
        out(i-N/2+1) = f(i+1);
    end    
    for (i=0:N/2-1)
        out(i+N/2+1) = f(i+1);
    end
end

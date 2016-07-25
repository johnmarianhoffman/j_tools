function results=filter_function(N)
% FILTER_FUNCTION Explorations in filtering using the fourier transform.    
% Variables:
%     x is filter
%     y is projection
%     z is filtered projection
%     s_ prepended means variable is in the spatial domain
%     f_ prepended means variable is in the fourier domain
%
%
% Assume all spatial measurements are in mm
%
% Last Modified by John Hoffman on 2015-06-19

    % Setup
    
    dt=595*sind(0.0678/2); % We replace "s" and "ds" with "t" and "dt" to avoid
            % confusion with the "s_" prepend notation.
    
    k1=(-N+1):(N-1); % Indexing for filter
    k2=0:(N-1); % Indexing for projection
    t=dt*(k2-(N-1)/2);

    % Prepare filter
    s_x=ramp(k1,dt,1,1); % ramp function at bottom of file
    % Prepare projection (circular disk with radius 200mm)
    s_y=2*sqrt(200^2-t.^2);
    for ii=1:numel(s_y)
        if ~isreal(s_y(ii))
            s_y(ii)=0;
        end
    end

    results.dt=dt;
    results.s_x=s_x;
    results.s_y=s_y;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute using FFT              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute the ffts of x,y manually

    M=2*2^ceil(log2(N));
    
    % Make X,Y
    Y=zeros(1,M);
    Y(1:N)=s_y(1:N);

    X=zeros(1,M);
    X(1:N)=s_x((floor(numel(s_x)/2)+1):end);
    X((M-N+2):M)=s_x(1:floor(numel(s_x)/2));

    results.X=X;
    results.Y=Y;
    
    G=ifft(fft(X).*fft(Y));
    results.X_f=real(fft(X));
    results.Y_f=real(fft(Y));
    G_im=imag(G);
    G_im=(G_im>1E-10);
    if (sum(G_im(:))~=0)
        disp('There may have been a problem in the FFT computation.  Imaginary values are greater than 1E-10.')
    end
    G=real(G(1:N));

    results.ft.s_z=G;

    % Calculate convolution
    results.conv.s_z.matlab=conv(s_y,s_x,'same');
    
    % Display results
    figure;
    subplot(1,3,1);
    plot(results.conv.s_z.matlab);

    subplot(1,3,2);
    plot(results.ft.s_z);

    subplot(1,3,3);
    plot(results.conv.s_z.matlab-results.ft.s_z);

    subplot(1,3,1);
    title('Convolution')
    subplot(1,3,2);
    title('FFT')
    subplot(1,3,3);
    title('Difference')

    
end

function f=ramp(k,ds,c,a)
% Simple function for creating filters
%
% Inputs:
%    k - list of indices (like [-200 -199 -198 ... 198 199])
%    ds - detector spacing (r_f*sin(fan_angle_increment/2))
%    c - [0,1]
%    a - [1, 0.5 0.54]
    
    f=(c^2/(2*ds))*(a*r(c*pi*k)+((1-a)/2)*r(pi*c*k+pi)+((1-a)/2)*r(pi*c*k-pi));
end

function vec=r(t)
vec=(sin(t)./t)+(cos(t)-1)./(t.^2);
vec(t==0)=0.5;
end
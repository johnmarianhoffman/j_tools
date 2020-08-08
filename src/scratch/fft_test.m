function fft_test(n_tests)
    
    data_size = 15000;
    
% Test power of 2 aligned
    data = rand(64,2^nextpow2(data_size),n_tests);
    size(data)
    a = tic;
    total = 0;
    for i=1:n_tests
        test = fft(data(:,:,i),[],2);
        total = total + test(1);
    end
    total_time = toc(a);
    fprintf("Average time per frame (aligned): %.5f (total %.3f)\n",total_time/n_tests,total_time);
    
    % Not power of 2 aligned
    data = rand(64,data_size,n_tests);
    size(data)
    a = tic;
    for i=1:n_tests
        test = fft(data(:,:,i),[],2);
        total = total+test(1);
    end
    total_time = toc(a);
    fprintf("Average time per frame (not aligned): %.5f (total %.3f)\n",total_time/n_tests,total_time);
    
    % Not power of 2 aligned
    data = rand(64,data_size,n_tests);
    a = tic;
    data = padarray(data,[0, (2^nextpow2(data_size)-data_size)/2, 0],0,'both');
    size(data)
    for i=1:n_tests
        test = fft(data(:,:,i),[],2);
        total = total+test(1);
    end
    %data = data(1:data_size,:,:);
    data = data(:,1:data_size,:);
    total_time = toc(a);
    fprintf("Average time per frame (padded): %.5f (total %.3f)\n",total_time/n_tests,total_time);
    
end
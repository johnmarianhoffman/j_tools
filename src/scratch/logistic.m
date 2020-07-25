function img = logistic()

%lambda = 0:0.001:5;

%
%data = compute_logistic(lambda,n);

% Allocate 8k image
w = 4*7680;
h = 4*4320;

img = zeros(h,w);

x_min = 3.5;
x_max = 4.0;
del_x = (x_max - x_min)/w;

y_min = 0.0;
y_max = 1.0;
del_y = (y_max - y_min)/h;

lambda = x_min:del_x:x_max;

n=2000;
data = compute_logistic(lambda,n);

for (i=500:2000)
    tmp = floor(data(:,i)/del_y);    
    for (j=1:numel(tmp))
        img(tmp(j)+1,j)=1;
    end    
end

end

function final_data = compute_logistic(lambda,n)

final_data = zeros(numel(lambda),n);

for (i=1:numel(lambda))
    curr_lambda = lambda(i);
    final_data(i,:) = run_one_logistic(curr_lambda,n);
end

end

function data = run_one_logistic(lambda,n)
    x = 0.5;
    data = zeros(1,n);
    for (i=1:n)
        x = lambda*x*(1.0 - x);
        data(i) = x;
    end
end
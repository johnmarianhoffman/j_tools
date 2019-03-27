function A = j_imrescale(A,range,varargin);

A = double(A);
a_max = max(A(:));
a_min = min(A(:));

disp(range);

if isempty(range)
    range = [a_min a_max];

end

A = ((A-range(1))/(range(2)-range(1)));

A(A<0) = 0;
A(A>1) = 1;

if (nargin==3)
    switch varargin{1}
      case 'uint8'
        A = uint8(255*A);
    end

end
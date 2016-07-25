function stack=hu(stack,varargin)
  if nargin==1
    h20=0.01923;
    air=0.0;
  elseif nargin==2
    h20=varargin{1};
  elseif nargin==3
    h20=varargin{1};
    air=varargin{2};
  end

  stack=1000*(stack-h20)/(h20-air);
  
end

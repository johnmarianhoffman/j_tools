function map = j_stoplight(length)

if nargin < 1
    length = size(get(gcf,'colormap'),1);
end

h = (0:length-1)' / (length-1) / 3;

if isempty(h)
	map = [];
else
	map = hsv2rgb([h ones(length, 1) repmat(.9, length, 1)]);
end

end

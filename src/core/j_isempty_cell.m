function m=j_isempty_cell(c)
m = false(size(c));
n_elems = numel(m);
for i=1:n_elems
    m(i) = ~isempty(c{i});
end
end
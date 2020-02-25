function no_clip(ax)

if nargin < 1
    ax = gca;


end

axis(ax,'off')
ax.Clipping = 'off'

end
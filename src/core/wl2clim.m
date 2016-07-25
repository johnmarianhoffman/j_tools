function clim=wl2clim(wl)

window=wl(1);
level=wl(2);

clim=[level-window/2 level+window/2];

end
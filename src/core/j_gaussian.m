function y=j_gaussian(x,m,s,scale)

y=scale*exp(-(x-m).^2./(2*s^2));

end
function y = maxparabolic(x,grid,idx) %- locate minima using parabolic interpolation
if idx==1 || idx==length(grid)
    y=grid(idx);
else
    delta=parabola(x(idx-1:idx+1));%Deviation to the center frequency. -1<delta<1
    y=grid(idx)+delta*diff(grid(1:2));
end
end
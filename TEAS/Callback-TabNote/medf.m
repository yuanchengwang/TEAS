function y1=medf(x1,L,N)
%
% Median filtering of sequence x1, of length N samples, with medians of
% length L.
% Code provided by Lawrence R. Rabiner, Rutgers University and
% University of California at Santa Barbara.
%   Input:
%   @x1: shoud be column vector
%   @L: the window length
%   @N: the length of x1
%   Ouput:
%   @y1: the median filtered results


%     x2=[ones(1,(L-1)/2).*x1(1) x1 ones(1,(L-1)/2).*x1(N)];
    x2=[ones((L-1)/2,1).*x1(1); x1; ones((L-1)/2,1).*x1(N)];
    y1=[];
    for i=1:N
        y=x2(i:i+(L-1));
        y1=[y1; median(y)];
    end
end
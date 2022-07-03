function g = loess_diw(x,y,newx,alpha,lambda)
%  curve fit using local regression
%  ysmooth = loess(x,y,newx,alpha,lambda,robustFlag)
%  apply loess curve fit -- nonparametric regression
%  x,y  data points
%  newx,ysmooth  fitted points
%  alpha  smoothing  typically 0.25 to 1.0
%  lambda  polynomial order 1 or 2

% Copyright (c) 1998 by Datatool
% $Revision: 1.00 $
%! Updated DIW 


% Scale x to [0,1] prevent ill conditioned fitting 
x1 = x(1); xr = max(x)-min(x); 
x = (x-x1)/xr; 
newx = (newx-x1)/xr;

g = NaN*newx; % space holder & get correct dimensions) 
lambda = round(lambda); % force polynm order to be integer 

n = length(x);      %  number of data points
%alpha = min(alpha,1); % clamp at 1 
q = min(max(floor(alpha*n),lambda+3),n); %  used for weight function width > 3 or so 

%  perform a fit for each desired x point
for ii = 1:length(newx)
   deltax = abs(newx(ii)-x);     %  distances from this new point to data
   deltaxsort = sort(deltax);     %  sorted small to large
   qthdeltax = deltaxsort(q);     % width of weight function
   arg = min(deltax/(qthdeltax*max(alpha,1)),1);
   tricube = (1-abs(arg).^3).^3;  %  weight function for x distance
   index = find(tricube>0);  %  select points with nonzero weights
   if length(index) > lambda
      p = least2(x(index),y(index),lambda,tricube(index));  %  weighted fit parameters
      newg = polyval(p,newx(ii));  %  evaluate fit at this new point
   else
      disp('Not enough points')
      newg = mean(y(index))+6; % keep same 
   end % if 
   g(ii) = newg;
end

end % function  
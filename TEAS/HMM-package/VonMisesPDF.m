function [z] = VonMisesPDF(F0,DELTA_F0,M,K,a,b,f0S,delta_f0S,state)
%VONMISESPDF gives the distribution of Von Mises
%   Input:
%   @F0: the f0.
%   @DELTA_FO: the first order diference of f0.
%   @M: the middle point. (Usually the Midi number)
%   @K and a, b: parameter for Von Mises distribution to change the width.
%   @f0S: streching parameter for f0
%   @delta_f0s: streching parameter for delta_f0
%   @state: indicate which state will use. 0: start and sustain, 1: end.
%   Output:
%   @z: the distribution.

    %create Von Mises distribution
%     r = sqrt(((F0-M).*f0S).^2+(DELTA_F0.*delta_f0S).^2)+1e-3;
    r = sqrt(((F0-M).*f0S).^2+(DELTA_F0.*delta_f0S).^2);
    
    cosTheta = ((F0-M).*f0S)./r;
    sinTheta = (DELTA_F0.*delta_f0S)./r;
    
    if state == 0
        %for 'start'
        cosAll = cosTheta.*cos(3/4*pi)+sinTheta.*sin(3/4*pi);
%         z = exp(K*(2*cosAll.^2-1)-a*r).*r.^(b-1);
        z = exp(K*(2*cosAll.^2-1)).*exp(-r*a).*r.^(b-1);
%         z = exp(K*(2*cosAll.^2-1)).*exp(-r*a);
    elseif state == 1
        %for 'sustain'
        z = exp(-r*a);
%         cosAll = cosTheta.*cos(3/4*pi)+sinTheta.*sin(3/4*pi);
%         z = exp(K*(2*cosAll.^2-1)).*exp(-r*a).*r.^(b-1);
    elseif state == 2
        %for 'end'
        cosAll = cosTheta.*cos(1/4*pi)+sinTheta.*sin(1/4*pi);
        z = exp(K*(2*cosAll.^2-1)).*exp(-r*a).*r.^(b-1);
    end
    
    %let the hole equal to maxmum value
    z(isnan(z)) = max(max(z));
    
%     z = z./sum(sum(z));
%     z = exp(K*(2*cosAll.^2-1)).*exp(-r*a);
        
    % z = exp(K*(2*cosAll.^2-1)).*pdf('Gamma',r,1,6);
    
    
    


end


function [ observationMatrixPower,observationMatrixPowerTemp ] = GetObservsMatrixPower( powerCurve,stateRangeTrans )
%GETOBSERVSMATRIXPOWER Gives the observation matrix for power curve which
%has the same state size as satetRangeTrans.
%   Input
%   @powerCurve: the power curve from the audio.
%   @stateRangeTrans: the state range for the transition matrix.
%   Ouput
%   @observationMatrixPower: the observation probability matrix

    %-------create observation matrix for power curve-------
    stateRangePower = [1,2];    %voiced and unvoiced
    observationMatrixPowerTemp = zeros(2,length(powerCurve));
    for i = 1:length(stateRangePower)
        if i == 1
            %voiced
            observationMatrixPowerTemp(i,:) = pdf('Gamma',powerCurve,1.5,4)*0.01;
        elseif i == 2
            %unvoiced
            observationMatrixPowerTemp(i,:) = normpdf(powerCurve,0,0.15)*0.01;    
        end
    end
    %expand the observation matrix of power to have the same size with
    %observation matrix
    observationMatrixPower = repelem(observationMatrixPowerTemp,length(stateRangeTrans)-1,1);
    observationMatrixPower = observationMatrixPower(1:length(stateRangeTrans),:);

    %new added
    observationMatrixPower(1,:) = observationMatrixPower(end,:);
    observationMatrixPower(end,:) = observationMatrixPower(end-1,:);
    %-------------------------------------------------------

end


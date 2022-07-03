function [ observsPitch ] = GetObservsMatrixBaseline( midiPitch,pitchRangeTrans )
%GETOBSERVSMATRIXBASELINE Return observation matrix for baseline HMM.
%   Input
%   @midiPitch: the f0 in midi scale
%   @pitchRangeTrans: state range for baseline HMM
%   Output
%   @observsPitch: the observation matrix(stateRangeTransStructure*T(signal length))

    %----create observation matrix-------
    %for new observation matrix (129*T(signal length))
    observsPitch = zeros(length(pitchRangeTrans),length(midiPitch));
    paraObservsPitch = [0,0]; %[mean,variance]
    for i = 1:size(observsPitch,1) 
        paraObservsPitch(1) = i-1;
        if i == 1
            paraObservsPitch(2) = 0.001;
        else
            paraObservsPitch(2) = 4;
        end
        observsPitch(i,:) = normpdf(midiPitch,paraObservsPitch(1),paraObservsPitch(2))*0.01;
    end
    %-------------------------------------

end


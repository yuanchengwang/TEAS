function [ observsTotal ] = GetObservsMatrixStructure( midiPitch, deltaMidiPitch,stateRangeMIDI, stateRangeTransition)
%GETOBSERVSMATRIX Return observation matrix for structure HMM.
%   Input
%   @midiPitch: the f0 in midi scale
%   @deltaMidiPitch: the corresponding delta-f0
%   @stateRangeMIDI: state range for MIDI Number
%   @stateRangeTransition: state range for transition. (up, steady, down).
%   Output
%   @observsTotal: the observation matrix(stateRangeTransStructure*T(signal length))

    %------------START of pitch observation matrix-----------------------
    numStatesMidi = length(stateRangeMIDI);
    numStatesTransition = length(stateRangeTransition);
    observsPitchTemp = zeros(numStatesMidi,length(midiPitch));
    
    %for midi number
    for i = 1:numStatesMidi  
        paraObservsPitch = [i,4];
        observsPitchTemp(i,:) = normpdf(midiPitch,paraObservsPitch(1),paraObservsPitch(2))*0.01;
    end
    observsPitch = repelem(observsPitchTemp,3,1);   %expand the rows
    
    %for silent part
%     paraObservsPitch = [0,0.001]; 
%     observsPitchSilent = normpdf(midiPitch,paraObservsPitch(1),paraObservsPitch(2))*0.01;
    
    %new PDF for silent part
    observsPitchSilent = size(midiPitch);
    observsPitchSilent(midiPitch == 0) = 0.9999;
    observsPitchSilent(midiPitch ~= 0) = (1-0.9999)/12800;
    
    %add silent part
    observsPitch = [observsPitchSilent;observsPitch];
    %----------------END of pitch observation matrix---------------------

    %-------START of delta pitch observation matrix---------
    observsDeltaPitchTemp = zeros(numStatesTransition,length(midiPitch));
    for i = 1:numStatesTransition %3 transition states
        if i == 1
            %TRANSITION-DOWN
%             paraObservsDeltaPitch = [-0.5,0.3];
            observsDeltaPitchTemp(i,:) = pdf('Gamma',-deltaMidiPitch,1.1,30);
        elseif i == 2
            %STEADY
%             paraObservsDeltaPitch = [0,0.015];
            paraObservsDeltaPitch = [0,0.010];  %0.014
            observsDeltaPitchTemp(i,:) = normpdf(deltaMidiPitch,paraObservsDeltaPitch(1),paraObservsDeltaPitch(2))*0.01;
        elseif i == 3
            %TRANSITION-UP
%             paraObservsDeltaPitch = [0.5,0.3]; 
            observsDeltaPitchTemp(i,:) = pdf('Gamma',deltaMidiPitch,1.1,30);
        end
        
    end
    %expand to 128 MIDI NN
    observsDeltaPitch = repmat(observsDeltaPitchTemp,128,1);
    
    %for silent part
    paraObservsDeltaPitch = [0,0.01];
    observsDeltaPitchSilent = normpdf(deltaMidiPitch,paraObservsDeltaPitch(1),paraObservsDeltaPitch(2))*0.01;
    
    observsDeltaPitch = [observsDeltaPitchSilent';observsDeltaPitch];
    %-----------END of delta pitch observation matrix---------------
    
    observsTotal= observsPitch.*observsDeltaPitch;
    

end


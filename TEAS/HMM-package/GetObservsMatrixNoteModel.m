function [ observation ] = GetObservsMatrixNoteModel( midiPitch,deltaMidiPitch,stateRangeMIDI,numStatesNoteModel)
%GETOBSERVSMATRIXNOTEMODEL Reture observation likelihood matrix for HMM
%note model (start-sustain-end)
%   Input:
%   @midiPitch: the f0 in midi scale
%   @deltaMidiPitch: the corresponding delta-f0
%   @stateRangeMIDI: state range for MIDI NN. e.g:%MIDI num 1:128 and 0 for silent
%   @numStatesNoteModel: the numbe of states for HMM note model
%   Output
%   @observsTotal: the observation matrix(numStatesNoteModel*T(signal length))

    %------START of observation matrix---------
    observation = zeros(numStatesNoteModel,length(midiPitch));
    for i = 1:numStatesNoteModel
        if mod(i,3) == 1
            %for start
            paraVonMises = [0.5,0.4,1,1,1];   %Original
%             paraVonMises = [0.5,0.4,1,1,1];
%             paraVonMises_2 = [0.5,0.4,1,60/100*pi];
            state = 0;
        elseif mod(i,3) == 2
            %for sustain
            paraVonMises = [0.5,0.1,1,5,1];
%             paraVonMises_2 = [0,0.1,1,0];
            state = 1;
        elseif mod(i,3) == 0
            %for end
            paraVonMises = [0.5,0.2,1,1,1];   %Original
%             paraVonMises = [0.5,0.2,1,1,1];
%             paraVonMises_2 = [0.5,0.2,1,30/100*pi];
            state = 2;
        end
        %new added
        observation(i,:) = VonMisesPDF(midiPitch,deltaMidiPitch,stateRangeMIDI(floor((i-1)/3)+1),paraVonMises(1),paraVonMises(2),paraVonMises(3),paraVonMises(4),paraVonMises(5),state);
%         observation(i,:) = VonMisesPDF_2(midiPitch,deltaMidiPitch,stateRangeMIDI(floor((i-1)/3)+1),paraVonMises_2(1),paraVonMises_2(2),paraVonMises_2(3),paraVonMises_2(4));
    end
    %------END of observation matrix-----------

end



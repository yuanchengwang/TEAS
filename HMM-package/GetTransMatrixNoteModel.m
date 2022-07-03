function [ transitionMatrix ] = GetTransMatrixNoteModel(stateRangeMIDI,noteModelSelfTranPro,noteTranSigma)
%GETTRANSMATRIXNOTEMODEL Return transition matrix for HMM Note Model
%note model (start-sustain-end)
%   Input:
%   @stateRangeMIDI: state range for MIDI NN. e.g:%MIDI num 1:128 and 0 for silent
%   @noteModelTranPro: the vector store note model self-transition
%   probabilities. [startSelf,sustainSelf,endSelf]
%   @noteTranMu: the mu for the note transition normal distribution
%   Output:
%   @transitionMatrix: transition matrix.

numStateRangeMIDI = length(stateRangeMIDI);
numStateNoteMode = 3; %every note has three states: start, sustain and end.

%left-right HMM of start-sustain-end.
% startSelf = 0.3; sustainSelf = 0.8; endSelf = 0.2;
startSelf = noteModelSelfTranPro(1);
sustainSelf = noteModelSelfTranPro(2);
endSelf = noteModelSelfTranPro(3);

%create the self transition probability.
diagonal1 = [startSelf sustainSelf endSelf];
diagonalMatrix1 = diag(repmat(diagonal1,1,numStateRangeMIDI));

%create the left-right transition probability for start and sustain states.
diagonal2 = [1-startSelf,1-sustainSelf,0];
diagonalMatrix2 = diag(repmat(diagonal2,1,numStateRangeMIDI),-1);

transitionMatrix = diagonalMatrix1+diagonalMatrix2(1:end-1,1:end-1);

%create the end state to each start state probabilities
transPitch = zeros(numStateRangeMIDI,numStateRangeMIDI);
for i = 1:numStateRangeMIDI
    if i == 1
        %for silent
        transPitch(:,i) = 1/numStateRangeMIDI*ones(size(transPitch(:,i)));
    else
        %for MIDI note
%         transPitch(:,i) = normpdf(stateRangeMIDI,stateRangeMIDI(i),4)'; %new added
        transPitch(:,i) = normpdf(stateRangeMIDI,stateRangeMIDI(i),noteTranSigma)';
    end
    
    %make each column sum to 1 (column stochastic)
    transPitch(:,i) = transPitch(:,i)/sum(transPitch(:,i))*(1-endSelf);
end

%incorporate the probability
for i = 1:size(transitionMatrix,2)
    if mod(i,numStateNoteMode) == 0
        for t = 1:size(transitionMatrix,1)
            if mod(t,numStateNoteMode) == 1
                transitionMatrix(t,i) = transPitch(floor(t/numStateNoteMode)+1,i/numStateNoteMode);
            end
        end
    end
end

end


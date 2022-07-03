function [ notesOutput ] = NotePruning( notesInput,durationThresh)
%NOTEPRUNING Delete any note that smaller than a threshold
%   Input:
%   @notesInput: the aggregated notes in cell arrarys. notesTotal{1,numCol}
%   indictes the notes from numCol'th column from midiTranscription matrix. 
%   In each cell, each row  is note in the form [starting time, MIDI NN, duration]
%   @durationThresh: the duration threshold for pruning. Any notes with
%   duritaion smaller this threshold will be deleted. (seconds)
%   Output:
%   @notesOutput:

    numCol = size(notesInput,2);
    notesOutput = cell(1,numCol);
    
    for i = 1:numCol
        notes = notesInput{1,i};
        notes(notes(:,3) < durationThresh,:) = [];   
        notesOutput{1,i} = notes;
    end
    
end


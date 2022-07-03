function [ transcribedDataRefined ] = noteRefinement( transcribedData,threshold)
%NOTEREFINEMENT This is to refine the notes from the HMM output. Basically,
%it start from the shortest note, calculate the weights of this shortest
%note to its previous and subsequent note, and decide which note it should
%be added to.
%   Input
%   @transcribedData: the transcribed note data. [start time:end time:MIDI]
%   @threshold: this is the threshold to classify whose duration lower than
%   this is deemed as short note.
%   Output
%   @transcribedDataRefined: the refined transcribed data. [start time:end time:MIDI]


    %---------START of note refinement from the shortest note--------
    duration = transcribedData(:,2)-transcribedData(:,1);
    [durationMin,durationMinIndex] = min(duration);

    while (durationMin < threshold)
        weightPre = 0;
        weightSub = 0;
    if (durationMinIndex ~= 1) && (durationMinIndex ~= length(duration))
        %calcuate the weights to previous note
        preIntervalPitch = abs(transcribedData(durationMinIndex,3)-transcribedData(durationMinIndex-1,3));
        preIntervalTime = abs(transcribedData(durationMinIndex,1)-transcribedData(durationMinIndex-1,2));
%         preDuration = duration(durationMinIndex-1);

        %calculate the weights to subsequent note
        subIntervalPitch = abs(transcribedData(durationMinIndex,3)-transcribedData(durationMinIndex+1,3));
        subIntervalTime = abs(transcribedData(durationMinIndex,2)-transcribedData(durationMinIndex+1,1));
%         subDuration = duration(durationMinIndex+1);

        %calculate the weight
        weightPre = normpdf(preIntervalPitch,0,1)+normpdf(preIntervalTime,0,1);
        weightSub = normpdf(subIntervalPitch,0,1)+normpdf(subIntervalTime,0,1);
    end
%     disp(durationMinIndex);
    if size(transcribedData,1)~=1
        if (durationMinIndex == length(duration)) || weightPre > weightSub 
            %if the short note is designated to previous note, add the short note
            %duration to the previous ending time.
            transcribedData(durationMinIndex-1,2) = transcribedData(durationMinIndex-1,2) + durationMin;
        elseif(durationMinIndex == 1) || weightPre < weightSub   
            %if the short note is designated to subsequent note, subtract the short
            %note duration from the subsequent starting time.
            transcribedData(durationMinIndex+1,1) = transcribedData(durationMinIndex+1,1) - durationMin;
        end
    end
    %delete the short note
    transcribedData(durationMinIndex,:) = [];

    duration = transcribedData(:,2)-transcribedData(:,1);
    [durationMin,durationMinIndex] = min(duration);

    end
    %---------END of note refinement from the shortest note--------
    transcribedDataRefined = transcribedData;
end


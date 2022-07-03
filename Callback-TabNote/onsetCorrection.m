function transcribedDataCorrected=onsetCorrection(transcribedData,onsetTime)
    %find onsets that within any transcribed note
    threshold = 0.1;    %in second, threshold let the interval of this value to the boundary not considered
    selectedPeaks = [];
    for i = 1:size(transcribedData,1)
        startTime = transcribedData(i,1)+threshold;
        endTime = transcribedData(i,2)-threshold;
        temp = onsetTime(onsetTime > startTime & onsetTime < endTime);
        if isempty(temp) == 0
            selectedPeaks = [selectedPeaks;[temp,zeros(length(temp),1)]];
            selectedPeaks(end-length(temp)+1:end,2) = i; %the corresponding num of note
        end
    end

    %get the added notes information
    if isempty(selectedPeaks) == 0
        addedNotes = zeros(size(selectedPeaks,1),3);
        uniqueCorrspNotes = unique(selectedPeaks(:,2));
        for i = 1:length(uniqueCorrspNotes)
            numInserted = sum((selectedPeaks(:,2) == uniqueCorrspNotes(i)));
            addedNotes((selectedPeaks(:,2) == uniqueCorrspNotes(i)),1) = selectedPeaks((selectedPeaks(:,2) == uniqueCorrspNotes(i)),1);

            numNowNote = sum(addedNotes(:,1) ~= 0);
            %in case if there are more than three notes for one original note
            for t = numNowNote:-1:numNowNote-numInserted+1
                %start from the last transcribed note
                if t == numNowNote
                    addedNotes(t,2) = transcribedData(uniqueCorrspNotes(i),2);
                else
                    addedNotes(t,2) = addedNotes(t+1,1);
                end
                addedNotes(t,3) = transcribedData(uniqueCorrspNotes(i),3); %the pitch is the same as the original note
            end
            transcribedData(uniqueCorrspNotes(i),2) = addedNotes(numNowNote-numInserted+1,1);
        end

        %add the added notes into the original notes and sort them by time
        totalNotes = [transcribedData;addedNotes];
        [~,order] = sort(totalNotes(:,1));
        transcribedDataCorrected = totalNotes(order,:);
    else
        transcribedDataCorrected = transcribedData;
    end
end
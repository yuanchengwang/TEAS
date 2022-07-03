function delTremoloFn(hObject,eventData)
%DELTREMOLOFN Summary of this function goes here
%   Detailed explanation goes here

    global data;
    
    if ~isempty(data.candidateNote)
        %delete the tremolo time information
        data.candidateNote(data.numTremoloSelected,:) = [];
        %delete the tremolo area patch in the plot
        delete(data.patchTremoloArea(data.numTremoloSelected));
        data.patchTremoloArea(data.numTremoloSelected) = [];

        %if the delelted tremolo is the last one, then go to the first
        if (data.numTremoloSelected == size(data.candidateNote,1)+1)
            data.numTremoloSelected = 1;
        end
        
        %
        plotHighlightFeatureArea(data.patchTremoloArea,data.numTremoloSelected,1);

        %plot the tremolo num in the listbox
        plotFeatureNum(data.candidateNote,data.tremoloListBox);

        %show the first tremolo in tremolo listbox
        data.tremoloListBox.Value = data.numTremoloSelected;

        %show individual candidate notes in the sub axes
        if isfield(data,'patchWaveCandidateNotes')
            delete(data.patchWaveCandidateNotes);
            data=rmfield(data,'patchWaveCandidateNotes');
        end
        cla(data.axeWaveTabTremoloIndi);
        if size(data.candidateNote,1)~=1
            time=data.candidateNote(data.numTremoloSelected,1:2);
            timerange=round(time(1)*data.fs):round(time(end)*data.fs);
            time=timerange/data.fs;
            audio=data.Cleaned_speech(timerange);
            xAxis = get(data.tremoloXaxisPara,'Value');
            if xAxis == 2%normalized time
                time=time-time(1);
            end
            plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
        end
    end
end


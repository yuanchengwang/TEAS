function delNoteFn(hObject,eventData)
%DELNOTEFN Delete note
global data;
if isfield(data,'NoteOnset')
    data.NoteOnset(data.numNoteSelected)=[];
    data.NoteDuration(data.numNoteSelected)=[];
    data.avgPitch(data.numNoteSelected)=[];
    data.notes(data.numNoteSelected,:)=[];
    if isfield(data,'fret')
        data.fret(data.numNoteSelected)=[];
    end
    if isfield(data,'velocity')
        data.velocity(data.numNoteSelected)=[];
    end
    if ~isempty(data.NoteOnset)
        if data.numNoteSelected>length(data.NoteOnset)
            data.numNoteSelected=length(data.NoteOnset);
        end
        data.NoteDetail=getPassages(data.pitchTime,data.pitch,[data.NoteOnset,data.NoteOnset+data.NoteDuration,data.NoteDuration],0);
        if isfield(data,'patchNoteArea')
            delete(data.patchNoteArea);
            data=rmfield(data,'patchNoteArea');
        end
        data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,data.avgPitch,data.axeOnsetOffsetStrength);
        hold on;
        plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,0);
        hold off;
        plotFeatureNum(data.NoteOnset,data.noteListBox);
        data.noteListBox.Value=data.numNoteSelected;
        time=data.notes(data.numNoteSelected,1:2);
        timerange=round(time(1)*data.fs):round(sum(time)*data.fs);
        time=timerange/data.fs;
        if isfield(data,'Cleaned_speech')
            audio=data.Cleaned_speech(timerange);
            xAxis = get(data.noteXaxisPara,'Value');
            if xAxis == 2%normalized time
                time=time-time(1);
            end
            plotAudio(time,audio,data.axePitchTabNoteIndi,data.NoisefileNameSuffix,1);
        end
        plotPitchFeature(data.NoteDetail,data.numNoteSelected,data.noteXaxisPara,data.axePitchTabNoteIndi);
        plotHighlightFeatureArea(data.patchNoteArea,data.numNoteSelected,1);
        note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
        data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1},'+',num2str(data.velocity(data.numNoteSelected))];
    else
        data=rmfield(data,'NoteOnset');
        data=rmfield(data,'NoteDuration');
        data=rmfield(data,'avgPitch');
        data=rmfield(data,'fret');
        data=rmfield(data,'velocity');
        data=rmfield(data,'notes');
        data.NoteXEdit.String=[];
    end
else
    msgbox('No note exists');
end
end
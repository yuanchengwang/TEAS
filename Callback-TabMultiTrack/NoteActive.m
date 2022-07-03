function NoteActive(hObject,eventData,p)
%NOTEACTIVE select plot+save bulletin for note
global data;
if data.CB.Note{p}.Value
    if isfield(data,'NoteTrack')
        if p<=length(data.NoteTrack)
            if ~isempty(data.NoteTrack{p})
                color=hsv(data.track_nb);
                hold on;
                yyaxis left;
                %avgPitch=MidiToFreq(data.NoteTrack{p}(:,4)+data.str{p});
                %data.plotNote{p}=plotNote(data.NoteTrack{p}(:,1),data.NoteTrack{p}(:,2),avgPitch,data.axeTabSynMIDI,color(p,:));
                data.plotNote{p}=plotNote(data.NoteTrack{p}(:,1),data.NoteTrack{p}(:,2),data.NoteTrack{p}(:,3),data.axeTabSynMIDI,color(p,:));
                hold off;
            else
                msgbox('No note input for this track.');
            end
        else
            msgbox('No note input for this track.');
        end
    else
        msgbox('No note input for this track.');
    end
else
    if isfield(data,'plotNote')
        delete(data.plotNote{p});
    end
end
end

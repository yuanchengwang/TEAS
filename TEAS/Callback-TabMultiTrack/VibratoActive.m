function VibratoActive(hObject,eventData,p)
%VIBRATOACTIVE select plot+save bulletin for vibrato
global data;
%plot vibrato
if data.CB.Vibrato{p}.Value
    if isfield(data,'VibratoTrack')
        if p<=length(data.VibratoTrack)
            if ~isempty(data.VibratoTrack{p})
                color=hsv(data.track_nb);
                hold on;
                yyaxis left;
                data.plotVibrato{p}=plotNote(data.VibratoTrack{p}(:,1),data.VibratoTrack{p}(:,3),data.VibratoTrack{p}(:,5),data.axeTabSynMIDI,color(p,:),'-');
                hold off;
            else
                msgbox('No vibrato input for this track.');
            end
        else
            msgbox('No vibrato input for this track.');
        end
    else
        msgbox('No vibrato input for this track.');
    end
else
    if isfield(data,'plotVibrato')
        delete(data.plotVibrato{p});
    end
end
end

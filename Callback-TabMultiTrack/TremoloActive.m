function TremoloActive(hObject,eventData,p)
%TREMOLOACTIVE select plot+save bulletin for tremolo
global data;
if data.CB.Tremolo{p}.Value 
    if isfield(data,'TremoloTrack')
        if p<=length(data.TremoloTrack)
            if ~isempty(data.TremoloTrack{p})
                color=hsv(data.track_nb);
                hold on;
                yyaxis left;
                data.plotTremolo{p}=plotNote(data.TremoloTrack{p}(:,1),data.TremoloTrack{p}(:,3),data.TremoloTrack{p}(:,4),data.axeTabSynMIDI,color(p,:),':');
                hold off;
            else
                msgbox('No tremolo input for this track.');
            end
        else
            msgbox('No tremolo input for this track.');
        end
    else
        msgbox('No tremolo input for this track.');
    end
else
    if isfield(data,'plotTremolo')
        delete(data.plotTremolo{p});
    end
end
end
function PortamentoActive(hObject,eventData,p)
%PORTAMENTOACTIVE select plot+save bulletin for portamento
global data;
%plot portamento area
if data.CB.Portamento{p}.Value
    if isfield(data,'PortamentoTrack')
        if p<=length(data.PortamentoTrack)
            if ~isempty(data.PortamentoTrack{p})
                color=hsv(data.track_nb);
                hold on;
                yyaxis left;
                data.plotPortamento{p}=plotNote(data.PortamentoTrack{p}(:,1),data.PortamentoTrack{p}(:,3),data.PortamentoTrack{p}(:,5),data.axeTabSynMIDI,color(p,:),'-.',data.PortamentoTrack{p}(:,6));
                hold off;
            else
                msgbox('No portamento input for this track.');
            end
        else
            msgbox('No portamento input for this track.');
        end
    else
        msgbox('No portamento input for this track.');
    end
else
    if isfield(data,'plotPortamento')
        delete(data.plotPortamento{p});
    end
end
end
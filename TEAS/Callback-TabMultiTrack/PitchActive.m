function PitchActive(hObject,eventData,p)
%PITCHactive check box control.
    global data;
    if data.CB.Pitch{p}.Value
        if isfield(data,'PitchTrack')
            if p<=length(data.PitchTrack)
                if ~isempty(data.PitchTrack{p})
                    color=hsv(data.track_nb);
                    hold on
                    yyaxis left;
                    data.plotPitch{p}=plotPitch(data.PitchTimeTrack{p},data.PitchTrack{p},data.axeTabSynMIDI,0,0,color(p,:));
                    hold off
                else
                    msgbox('No pitch input for this track.');
                end
            else
                msgbox('No pitch input for this track.');
            end
        else
            msgbox('No pitch input for this track.');
        end
    else
        if isfield(data,'plotPitch')
            delete(data.plotPitch{p});
        end 
    end
end
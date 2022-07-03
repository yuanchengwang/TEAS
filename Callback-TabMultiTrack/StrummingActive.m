function StrummingActive(hObject,eventData)
%STRUMMINGACTIVE select plot+save bulletin for strumming
global data;
if data.CB.Strumming.Value
    if isfield(data,'StrummingTrack')
        data.plotStrum=plotFeaturesArea(data.StrummingTrack,data.axeTabSynMIDI);
    else
        msgbox('No strumming area input.');
    end
else
    if isfield(data,'plotStrum')
        delete(data.plotStrum)
    end
end
end
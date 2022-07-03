function changePitchMetric(hObject,eventData)
%CHANGEPITCHMETRIC Choose MIDI or Freq metric for selected pitch point
    global data;
    if ~isempty(data.PitchXEdit.String)
        model=get(data.PitchXaxisPara,'value');
        if model==1%freq
            data.PitchXEdit.set('string',num2str(data.pitch(data.pitchIndex)));
        else%MIDI
            data.PitchXEdit.set('string',num2str(data.pitchPoint));
        end
    end
end
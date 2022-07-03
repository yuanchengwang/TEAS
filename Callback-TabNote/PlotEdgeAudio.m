function PlotEdgeAudio(hObject,eventData)
%denoisedactive check box control.
    global data;
    if data.CB.plot_audio.Value
        if isfield(data,'Cleaned_speech')
        data.plotEdgeWave=plotAudio((1:size(data.Cleaned_speech,1))/data.fs,data.Cleaned_speech,data.axeOnsetOffsetStrength,data.NoisefileNameSuffix,1); 
        end
    else
        if isfield(data,'plotEdgeWave')
            delete(data.plotEdgeWave);
        end
    end
end
function DownPitchFn(hObject,eventData)
%DOWNPITCH An octave down for selected point(s).
global data;
if isfield(data,'pitchIndex')
%clear Note
if isfield(data,'onset')
    data=rmfield(data,'onset');
end
if isfield(data,'offset')
    data=rmfield(data,'offset');
end
plotClearFeature('Note');
if isfield(data,'NoteOnset')
    data = rmfield(data,'NoteOnset');
    data = rmfield(data,'NoteDuration');
    data = rmfield(data,'avgPitch');
    if isfield(data,'fret')
        data = rmfield(data,'fret');
    end
end
%clear vibrato
plotClearFeature('Vibrato');
if isfield(data,'FDMoutput')
    data = rmfield(data,'FDMoutput');
end
if isfield(data,'PERoutput')
    data = rmfield(data,'PERoutput');
end
%clear portamento
plotClearFeature('Portamento');

data.pitch(data.pitchIndex)=data.pitch(data.pitchIndex)/2;
data=rmfield(data,'pitchPointArea');
plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio,1,1);
plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,1);
plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato,0,1);
plotPitch(data.pitchTime,data.pitch,data.axePitchTabPortamento,0,1);
if data.CB.plot_audio.Value
    data.plotEdgeWave=plotAudio((1:size(data.Cleaned_speech,1))/data.fs,data.Cleaned_speech,data.axeOnsetOffsetStrength,data.NoisefileNameSuffix,1); 
end
data.pitchPoint=freqToMidi(data.pitch(data.pitchIndex));
data.pitchPointArea = plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio); 
if isscalar(data.pitchPoint)  
    model=get(data.PitchXaxisPara,'value');
    if model==2%freq
        data.PitchXEdit.set('string',num2str(data.pitch(data.pitchIndex)));
    else%MIDI
        data.PitchXEdit.set('string',num2str(data.pitchPoint));
    end
end
else
    msgbox('No pitch point(s) selected');
end
end
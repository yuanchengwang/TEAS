function modPitchFn(hObject,eventData)
%MODPITCHFN modify pitch value and plot the new pitch
    global data;
    if ~isempty(data.PitchXEdit.String)
        model=get(data.PitchXaxisPara,'value');
        number=str2num(data.PitchXEdit.String);
        midi=notename(data.pitchPoint);
        data.PitchXMIDI.set('string',num2str(midi{1}));
        if model==1%freq
            data.pitch(data.pitchIndex)=number;
            data.pitchPoint=freqToMidi(number);
        else%MIDI
            data.pitchPoint=number;
            data.pitch(data.pitchIndex)=MidiToFreq(number);
        end
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
        data=rmfield(data,'pitchPointArea');
        data.pitchPointArea = plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio); 
        plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio,1,1);
        plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,1);
        plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato,0,1);
        plotPitch(data.pitchTime,data.pitch,data.axePitchTabPortamento,0,1);
        if data.CB.plot_audio.Value
            data.plotEdgeWave=plotAudio((1:size(data.Cleaned_speech,1))/data.fs,data.Cleaned_speech,data.axeOnsetOffsetStrength,data.NoisefileNameSuffix,1); 
        end
    end
end


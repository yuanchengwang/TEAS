function denoisingFn(hObject,eventData)
% Main function for denoising %   Detailed explanation goes here
global data;
if ~isfield(data,'audio')
    msgbox('No input audio');
else
    data.NoisefileNameSuffix=[data.fileNameSuffix(1:end-4),'_DenoisedWave',data.fileNameSuffix(end-3:end)];
    method = get(data.denoisingMethodChange,'Value');
    %clear Pitch
    cla(data.axePitchTabAudio);
    if isfield(data,'pitch')
        data = rmfield(data,'pitch');
        data = rmfield(data,'pitchTime');
    end
    %clear Note
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
    if method==1%None, no method, plot raw audio directly
        data.Cleaned_speech=data.audio;
        plotAudio(data.time,data.Cleaned_speech,data.axedenoisedWave,data.fileNameSuffix,0);  
        plotAudio(data.time,data.Cleaned_speech,data.axePitchWave,data.fileNameSuffix,0);
        plotAudio(data.time,data.Cleaned_speech,data.axeWaveTabTremolo,data.fileNameSuffix,0);
        %temporary cleaned speech audio, for pitch detection task
        delete('temp\*')
        audiowrite(['temp\',data.fileName,'.wav'],data.Cleaned_speech,data.fs);
    elseif method==2%MMSE
        %Y. Ephraim and D. Malah, ¡°Speech enhancement using a minmum mean-square error log-spectral amplitude
        % estimator,¡± IEEE Transactions on Acoustics, Speech and Signal Processing, vol. 33, pp. 443¨C445, 1985.
        if isfield(data,'noise_range')
            data.Cleaned_speech=Denoising(data.audio,data.fs,data.noise_range);
            plotAudio(data.time,data.Cleaned_speech,data.axedenoisedWave,data.fileNameSuffix,0);
            plotAudio(data.time,data.Cleaned_speech,data.axePitchWave,data.fileNameSuffix,0);
            plotAudio(data.time,data.Cleaned_speech,data.axeWaveTabTremolo,data.fileNameSuffix,0);
            %temporary cleaned speech audio, for pitch detection task
            delete('temp\*')
            audiowrite(['temp\',data.fileName,'.wav'],data.Cleaned_speech,data.fs);
        else
            msgbox('No noise area selected,please add a noise area or push noise candidate(s) button which will choose the longest noise area as noise range automatically calculated from the LEQ method.You could also select a candidate noise area as noise range.');
        end
    else%high pass
        cut_freq=round(MidiToFreq(min(cell2mat(data.str)))*3/4,-1);%80,110*3/4=82.5
        [b,a]=butter(7,cut_freq/(data.fs/2),'high');%order cannot be >= 8 if cut frequency=82.5
        data.Cleaned_speech=filter(b,a,data.audio);
        plotAudio(data.time,data.Cleaned_speech,data.axedenoisedWave,data.fileNameSuffix,0);
        plotAudio(data.time,data.Cleaned_speech,data.axePitchWave,data.fileNameSuffix,0);
        plotAudio(data.time,data.Cleaned_speech,data.axeWaveTabTremolo,data.fileNameSuffix,0);
        %temporary cleaned speech audio, for pitch detection task
        delete('temp\*')
        audiowrite(['temp\',data.fileName,'.wav'],data.Cleaned_speech,data.fs);
    end
    if isfield(data,'Cleaned_speech_spec')
        data=rmfield(data,'Cleaned_speech_spec');
    end
    if isfield(data,'mel_spec')
        data=rmfield(data,'mel_spec');
    end
end
end
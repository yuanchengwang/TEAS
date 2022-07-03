function DenoisedActive(hObject,eventData,p)
%denoisedactive check box control.
    global data;
    if data.CB.MIDIDenoisedWave{p}.Value
        for i=1:data.track_nb+1%only one single checkbox to plot the audio
            if i~=p
                data.CB.MIDIDenoisedWave{i}.Value=0;
            end
        end
        if isfield(data,'denoisedWaveTrack')
            if p<=length(data.denoisedWaveTrack)
                if ~isempty(data.denoisedWaveTrack{p})
                    if isfield(data,'plotsynWave')
                        delete(data.plotsynWave);
                    end
                    hold on;
                    data.plotsynWave=plotAudio((1:size(data.denoisedWaveTrack{p},1))/data.fs,data.denoisedWaveTrack{p},data.axeTabSynMIDI,['Track ',num2str(p)],1); 
%                     if p==data.track_nb+1
%                         title(data.denoisedWaveTrackSuffix{p});
%                     end
                    hold off;
                else
                    msgbox('No audio input for this track.');
                end
            else
                if isfield(data,'plotsynWave')
                    delete(data.plotsynWave);
                end
                msgbox('No audio input for this track.');
            end
        else
            msgbox('No audio input for this track.');
        end
    else
        if isfield(data,'plotsynWave')
            delete(data.plotsynWave);
        end
    end
end
function OnsetDetectionFn(hObject,eventData)
%ONSETDETECTIONFN run the onset detection only, offset in offsetDetectionFn
    global data;
    model=get(data.OnsetOffsetMethodChange,'Value');
    if isfield(data,'Cleaned_speech')
        if ~isfield(data,'EdgeTime') || ~isfield(data,'Cleaned_speech_spec')
            [data.Cleaned_speech_spec,data.EdgeTime]=spect_onset(data.Cleaned_speech);
        end
        [data.onset,data.onset_env]=onset_detector(data.Cleaned_speech_spec,model); %data.EdgeTime
        data.onset(data.onset>length(data.onset_env)-4)=[];%remove the onset peaks at the tail,4 frames
        data.onset(data.onset<=4)=[];%remove the onset at the beginning
        data.offset=[];%临时的
        %data.offset_env
        %plotting
        if isfield(data,'patchFeaturesPoint')
            delete(data.patchFeaturesPoint);
            data=rmfield(data,'patchFeaturesPoint');
        end
        % plot
        if model~=4
            data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);%data.HD_offset_new
        else
            data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);%data.HD_offset_new
        end
    else
        msgbox('No denoised signal.');
    end
end
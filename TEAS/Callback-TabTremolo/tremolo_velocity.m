function tremolo_vel=tremolo_velocity(onset)
%Velocity estimation returns the log-RMC energy, input onset in sec
global data;
if ~isfield(data,'energy')
    if data.double_peak
        if ~isfield(data,'log_energy_spec')
            %close to RMS get from
            if isfield(data,'Cleaned_speech')
                if data.double_peak==1
                    win=hann(data.win_length/2,'periodic');%for log-energy
                else
                    win=hann(data.win_length,'periodic');%for other methods
                end
                [data.log_energy_spec,data.log_energy_FFF,data.log_energy_time]=spectrogram(data.Cleaned_speech,win,round(data.win_length/2-data.hop_length),data.win_length/2,data.fs);
            else
                uiwait(msgbox('No denoised signal!'));
            end
        end
        data.energy=sum(abs(data.log_energy_spec(6:end,:)),1);
    else
        if ~isfield(data,'energy')
            %close to RMS get from
            if ~isfield(data,'Cleaned_speech')
                [data.Cleaned_speech_spec,data.EdgeTime]=spect_onset(data.Cleaned_speech);
            else
                uiwait(msgbox('No denoised signal!'));
            end
            data.energy=sum(abs(data.Cleaned_speech_spec(6:end,:)),1);%not get from power spectrum X^2
        end
    end
end
onset=round(onset*data.fs/data.hop_length);%the approximate frame index
%Normalization and discretization
tremolo_vel=min(127,max(0,round(data.gain*round(20*log10(data.energy(onset))))-1))';%-1 for encoding
end

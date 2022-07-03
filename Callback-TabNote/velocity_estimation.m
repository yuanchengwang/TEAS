function velocity_estimation(velocity)
%Velocity estimation returns the log-RMC energy
global data;
if ~isempty(velocity) %modify the velocity for a selected note for ModNoteFn
    if floor(velocity)==velocity && velocity<0 && velocity>127 %0-127 is for encoding, the level=1-128.
        msgbox('Velocity value must be an integer between 0-127.');
        return
    end
    if isfield(data,'numNoteSelected')%modify the velocity
        data.velocity(data.numNoteSelected)=velocity;
    end
else%compute velocity for all notes
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
    if data.double_peak
        if ~isfield(data,'onset')
            uiwait(msgbox('No onset detected, run onset detection or import onsets first.'));
            return   
        end
        if mod(length(data.onset),2)~=0
            uiwait(msgbox('Odd onset number. Correct the onsets first.'));
            return
        end
        onset=data.onset(2:2:end);%the approximate frame index
    else
        if ~isfield(data,'onset') && ~isfield(data,'notes')
            uiwait(msgbox('Neither onsets nor note detected'));
            return
        end
        if isfield(data,'notes')
            onset=max(round(data.notes(:,1)*data.fs/data.hop_length),1);%the approximate frame index
        end
        if isfield(data,'onset')%priority
            onset=data.onset;
        end
    end
    data.velocity_fine=data.energy(onset); 

    %Normalization and discretization
    velocity=min(127,max(0,round(data.gain*round(20*log10(data.velocity_fine)))-1))';%-1 for encoding
    if isfield(data,'notes')
        if size(data.notes,1)~=size(velocity,1)
            strength=data.notes(:,1);
            data.velocity=zeros(length(strength),1);
            
            if data.double_peak
                onset=data.onset(1:2:end)*data.hop_length/data.fs;   
            else
                onset=data.onset*data.hop_length/data.fs;
            end
            if size(data.notes,1)>size(velocity,1)
            j=1;
            for i=1:length(strength)
                [~,b]=min(abs(strength(i)-onset));
%                 if a<0.01
                data.velocity(b)=velocity(j);
                if j<length(velocity)
                    j=j+1;
                end
%                 end
            end
            else
                for i=1:length(strength)
                    [~,b]=min(abs(strength(i)-onset));
                    data.velocity(i)=velocity(b);
                end
            end
        else
            data.velocity=velocity;
        end
    else
        data.velocity=velocity;
    end
    %data.velocity=velocity;
end
end
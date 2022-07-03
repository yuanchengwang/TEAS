function [onset,HD_onset]=onset_detector(spec,model,varargin)%offset,HD_offset
% Onset detector with specflux+max filtering(superflux)+LGD weighting
% REFERENCE: implemented by yuancheng wang
%Sebastian Bock and Gerhard Widmer. Maximum filter vibrato suppression for onset detection. In Proceedings of the 16th International Conference on Digital Audio Effects (DAFx-13), Maynooth,Ireland, September 2013.
%Sebastian Bock and Gerhard Widmer. Local group delay based vibrato and tremolo suppression for onset detection. Proceedings of the 13th International Society for Music Information Retrieval Conference (ISMIR), Curitiba, Brazil, November 2013.
%Qingyang Xi,Rachel M. Bittner,Johan Pauwels, Xuzhou Ye,Juan P. Bello. GuitarSet: A dataset for guitar transcription. 19th International Society for Music Information Retrieval Conference, Paris, France, 2018.
global data;
epsilon=1e-10;
top_db=80;
data.energy=sum(abs(spec(6:end,:)),1);
if model==1%SpecFlux
    max_size=1;
elseif model==2 || model==3%SuperFlux+LGD
    max_size=3;%for both frequency and time axis.
else%model=4 means log energy
    max_size=1;
end
c=floor(max_size/2);
% Mel filter/quarter-tone spacing
if model==4%model= log energy
    %winsize=1024, 4522+
    win=hann(data.win_length/2,'periodic');
    [data.log_energy_spec,data.log_energy_FFF,data.log_energy_time]=spectrogram(data.Cleaned_speech,win,round(data.win_length/2-data.hop_length),data.win_length/2,data.fs);
    spec= 10 * log10(max(1e-10,abs(data.log_energy_spec(106:end,:))));%power2db,replace the spec
    spec=max(spec,max(max(spec))-80);
    energy=sum(spec);
    energy=energy-min(energy);
    data.log_energy=energy/max(energy);
    HD_onset=data.log_energy;
else
    if ~isfield(data,'mel_spec')
        [data.mel_spec,data.F_new,data.BW]=mel_spect_onset(data.Cleaned_speech_spec);
    end
    %log filtering%librosa
    D=10 * log10(max(epsilon,data.mel_spec));%power2db
    D=max(D,max(max(D))-top_db);
     %imagesc(D,F_new)
    %max_filtering 1D,mu=1, mu=2 in paper
    R=D;
    if max_size~=1
        D_padded=[D(c:-1:1,:);D;D(end:-1:end-c+1,:)];%reflect
        for m=1:size(D,1)
            R(m,:)=max(D_padded(m:m+2*c,:));
        end
    end
    diff=D(:,2:end)-R(:,1:end-1);
    HD1=max(0,diff);
    HD_onset=sum(HD1,1);%Diff+half rectifier to suppress the vibrato,[F,T-1]
    HD2=-min(0,diff);
    %HD_offset=sum(HD2,1);
    %imagesc(HD);
    %plot(sum(HD))

    %Complexflux
    if model==3
    LGD=unwrap(angle(spec(2:end,:)))-unwrap(angle(spec(1:end-1,:)));%[F-1,T],raw spec
    %imagesc(abs(LGD))

    %max_filter along the time axis 
    LGR=LGD;
    T=size(LGD,2);
    LGR(:,1)=max(abs(LGD(:,1:2)),[],2);
    LGR(:,T)=max(abs(LGD(:,T-1:T)),[],2);
    for t=2:T-2
       LGR(:,t)=max(abs(LGD(:,t-c:t+c)),[],2);
    end
    %imagesc(LGR)
    %min_filter for each Melfilter
    W=zeros(size(HD1,1),T);
    %Convert frequency value into frequency bin, fs/2/1024
    K_L=ceil((data.F_new-data.BW/2)/(data.fs/data.hop_length));%ceil+1
    K_U=ceil((data.F_new+data.BW/2)/(data.fs/data.hop_length))+1;%floor+1=ceil%sum(K_U>K_L) to evaluate
    for m=1:size(HD1,1)
       W(m,:)=min(LGR(K_L:K_U,:));%[M,T]
    end
    %SF1=HD.*W(:,1:end-1);
    SF1=HD1.*W(:,2:end);
    %SF2=HD2.*W(:,2:end);
    %imagesc(SF)
    % hold on
    % %plot(sum(SF1)/max(sum(SF1)))
    % plot(sum(SF2)/max(sum(SF2)))
    % plot(sum(HD)/max(sum(HD)))
    % hold off
    HD_onset=sum(SF1,1);
    %HD_offset=sum(SF2,1);
    end
    if nargin==3
        HD_onset=HD_onset.*data.energy(1:end-1);%(log(data.energy(1:end-1))-log(data.energy(2:end)))./data.energy(2:end);
    end
    %Normalization
    HD_onset=(HD_onset-min(HD_onset))/max(HD_onset);
end
    
    %HD_offset=HD_offset/max(HD_offset);%normalization of offset in
    %offset_pick.m
%Peak picking
%Reference papers:30 ms,30 ms,100 ms,70 ms,0.1,30 ms;
%librosa:30 ms,0 ms,100 ms,100 ms, 0.07,30 ms;

if nargin==2 && model~=4%Parameter from original paper.
    onset=peak_pick(HD_onset,round(0.03*data.fs/data.hop_length),round(0.03*data.fs/data.hop_length),round(0.1*data.fs/data.hop_length),round(0.07*data.fs/data.hop_length),0.1,round(0.03*data.fs/data.hop_length));
else%Tremolo.0.05
    onset=peak_pick(HD_onset,round(0.025*data.fs/data.hop_length),round(0.025*data.fs/data.hop_length),round(0.25*data.fs/data.hop_length),round(0.025*data.fs/data.hop_length),0.025,round(0.025*data.fs/data.hop_length));
end
%energy_mode=1;
%Onsets corrected with energy.


%offset using offset curve+energy, wait=0.1
%[offset,data.HD_offset_new]=offset_pick(HD_offset,onset,data.energy,round(0.03*data.fs/data.hop_length),round(0.03*data.fs/data.hop_length),round(0.1*data.fs/data.hop_length),round(0.07*data.fs/data.hop_length),0.1,round(0.1*data.fs/data.hop_length),energy_mode);
%offset using energy only.
%Alignment
if model==4
align=floor(data.win_length/4/data.hop_length);%due to different window size
else
align=floor(data.win_length/2/data.hop_length);
end
onset=onset+align;

% if model~=4
%     %%修正
%     [onset,max_energy]=onsetEnergyCorrect(onset,data.energy);
%     offset=offset_pick_energy(onset,data.energy,max_energy,round(0.1*data.fs/data.hop_length));
%     %data.HD_offset_new=HD_offset;
%     offset=offset+align;
% else
%     offset=[];
%     %HD_offset=[];
% end

end
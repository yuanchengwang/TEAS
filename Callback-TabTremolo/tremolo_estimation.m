function tremolo_estimation(flag)
%Tremolo_estimation function. Get the tremolo parameters from the candidate
%notes.
global data;
if isfield(data,'Cleaned_speech')
    if ~isfield(data,'Clean_speech_spec')
        [data.Cleaned_speech_spec,data.EdgeTime]=spect_onset(data.Cleaned_speech);
    end
else
    msgbox('No denoised signal.')
    return
end
if data.changeTremoloMethod.Value==1%log-energy
    [onset,data.onset_env_tremolo]=onset_detector(data.Cleaned_speech_spec,4,1);%onset+onset_env_tremolo
    onset=onset*data.hop_length/data.fs;
    data.timerange=zeros(size(data.candidateNote,1),length(onset));
elseif data.changeTremoloMethod.Value==2%Specflux
    [onset,data.onset_env_tremolo]=onset_detector(data.Cleaned_speech_spec,1,1);%onset+onset_env_tremolo
    onset=onset*data.hop_length/data.fs;
    data.timerange=zeros(size(data.candidateNote,1),length(onset));
elseif data.changeTremoloMethod.Value==3%SpecSlope for audio case (Only for audio recording with fake nail noise)
    spec=abs(data.Cleaned_speech_spec);
    spec= 10 * log10(max(1e-10,spec));%power2db
    spec=max(spec,max(max(spec))-80);
    SS= spectralSlope(spec,data.FFF);%onset+onset_env_tremolo
    SS=max(0,-SS);
    SS=SS-min(SS);
    data.onset_env_tremolo=SS/max(SS);
    onset=peak_pick(data.onset_env_tremolo,round(0.03*data.fs/data.hop_length),round(0.03*data.fs/data.hop_length),round(0.03*data.fs/data.hop_length),round(0.03*data.fs/data.hop_length),0.03,round(0.03*data.fs/data.hop_length));
    onset=onset*data.hop_length/data.fs;
    data.timerange=zeros(size(data.candidateNote,1),length(onset));
% else%FDM
%     if ~isfield(data,'energy')
%         data.energy=sum(abs(data.Cleaned_speech_spec(6:end,:)),1);
%     end
%     for i=1:size(data.candidateNote,1)
%         [~,timerange1]=min(abs(data.candidateNote(i,1)-data.EdgeTime));
%         [~,timerange2]=min(abs(data.candidateNote(i,2)-data.EdgeTime));
%         %FDM...
%         %treParaName = {'Strength(Initial):','Pluck No.:','Rate(Hz):','Dynamic Uniformity:','Speed Uniformity:','Note Types:'}
%         
%         if data.tremoloPara{i,2}>2
%             data.tremoloPara{i,3}=1/mean(diff(data.onset_tremolo{i}));
%            if data.track_index==1
%                 data.candidateNote(i,5)=2;%Wheel
%            else
%                data.candidateNote(i,5)=4;%Shaking by default for the other strings
%            end
%         elseif data.tremoloPara{i,2}==2
%             disp(i);
%             %msgbox('Two normal plucks detected within a note, modify the pluck points or note segment in note tab.');
%             return
%         end     
%     end
end
%onset(onset>length(data.onset_env_tremolo)-4)=[];%remove the onset peaks at the tail,4 frames
%onset(onset<=0.02)=[];%remove the onset at the beginning
if flag
data.candidateNote(:,5)=1;%Preset every candidate note is normal
data.tremoloPara=cell(size(data.candidateNote,1),length(data.treParaName));
data.onset_tremolo=cell(1,size(data.candidateNote,1));
if data.double_peak
onset_vel=data.onset(2:2:end)*data.hop_length/data.fs;
end
for i=1:size(data.candidateNote,1)
    % Extract the onsets    
    data.timerange(i,:)=(data.candidateNote(i,1)<onset).*(data.candidateNote(i,2)>onset);
    if sum(data.timerange(i,:))==0
        disp([num2str(i),': No pluck.']);
        continue
    end
    onset_tmp=onset(logical(data.timerange(i,:)));
    onset_tmp(onset_tmp-data.candidateNote(i,1)<0.01)=[];%remove the pluck at the beginning
    onset_tmp(data.candidateNote(i,2)-onset_tmp<0.04)=[];%remove the pluck at the end
    
    if data.double_peak%if existing onset
        ind=find(abs(onset_vel(i)-onset_tmp)<0.025,1);
        if isempty(ind)
            onset_tmp=[onset_tmp,onset_vel(i)];
        end
    end
    data.onset_tremolo{i}=sort(onset_tmp);
    if data.double_peak
        data.tremoloPara{i,1}=tremolo_velocity(data.onset_tremolo{i}(1));
        data.tremoloPara{i,2}=(length(onset_tmp)+1)/2;%nb of the plucks within a candidate note +1 for the note onset.
    else
        if isfield(data,'PTfreelist')%note edge=onset
            data.tremoloPara{i,1}=tremolo_velocity(data.candidateNote(data.PTfreelist(i),1));%Initial velocity of tremolo
        else
            data.tremoloPara{i,1}=tremolo_velocity(data.notes(i,1));
        end
        data.tremoloPara{i,2}=sum(data.timerange(i,:))+1;%nb of the plucks within a candidate note +1 for the note onset.      
    end
    data.tremoloPara{i,3}=nan;
    if data.tremoloPara{i,2}>=2
       if data.double_peak
           data.tremoloPara{i,3}=1/mean(diff([data.candidateNote(i,1),data.onset_tremolo{i}(2:2:end)]));%rate
       else
           data.tremoloPara{i,3}=1/mean(diff([data.candidateNote(i,1),data.onset_tremolo{i}]));
       end
       if data.track_index==1%type
            data.candidateNote(i,5)=2;%Wheel
       else
           data.candidateNote(i,5)=4;%Shaking by default for the other strings
       end
    end
    if mod(data.tremoloPara{i,2},2)==0 && data.double_peak%pluck
        disp([num2str(i),': Odd pluck number.']);
        %msgbox('Two normal plucks detected within a note, modify the pluck points or note segment in note tab.');
    end   
end
end
end
function [onset,duration,avgPitch]=hmm_baseline(pitch,time,h,varargin)
%HMM_baseline: Pitch2note using midi spelling only based HMM
% Reference: Baseline method in PROBABILISTIC TRANSCRIPTION OF SUNG MELODY USING A PITCH DYNAMIC MODEL
global data;
tau=10;%the shortest note to keep(sec)
offsetTime=[];
if nargin>3 %&& data.CB.auto_NoteEdge.Value
    if data.double_peak%log-energy
        onsetTime=varargin{1}'*data.hop_length/data.fs;
        %onsetTime2=onsetTime(2:2:end);
        onsetTime=onsetTime(1:2:end);%only the pluck get
    else     
        onsetTime=varargin{1}'*data.hop_length/data.fs;
    end

    if nargin==5
       offsetTime=varargin{2}'*data.hop_length/data.fs;
    end
% else%Original version for onset detection
%     widowLengthf0 = data.win_length/2;%1024
%     pitchFs = 1/(time(2)-time(1));
%     stepf0 = round(data.fs/pitchFs);
%     onsetTime = onsetCorrectFlux(data.Cleaned_speech,widowLengthf0,stepf0,data.fs);%corrected specflux
end
waitbar(0.1,h,sprintf('%d%% Pitch2Note converting...',10));
zero_position=pitch>0;
diff_zeros_position=diff(zero_position);
down=find(diff_zeros_position==-1);
up=find(diff_zeros_position==1)+1;
if zero_position(1)==1
    segment(1,1)=1;
    segment(2:1+length(up),1)=up;
else
    segment(:,1)=up;
end
if zero_position(end)==1
    segment(1:length(down),2)=down;
    segment(length(down)+1,2)=length(zero_position);
else
    segment(:,2)=down;
end
%tau=ceil(threshold/(time(2)-time(1)));
segment=segment(diff(segment,[],2)>=tau,:);%eliminate the note too short
pitchDeviation = GetPitchDeviation(pitch);

onset=[];
duration=[];
if nargin==3
    for i=1:size(segment,1)
    waitbar(round(10+70/size(segment,1))/100,h,sprintf('%d%% Pitch2Note converting...',round(10+70/size(segment,1))));
    [onset_temp,duration_temp]=hmm_baseline_core(pitch(segment(i,1):segment(i,2)),time((segment(i,1):segment(i,2))),pitchDeviation);
    onset=[onset;onset_temp];
    duration=[duration;duration_temp];
    end
else
    onset=onsetTime;
    if nargin==4
        for i=1:size(segment,1)
            [~,pos]=min(abs(segment(i,1)-onset));
            i=1;
            while onset(pos+i)<segment(i,2)
                offsetTime=[offsetTime;onset(pos+i)];
                i=i+1;
            end
            offsetTime=[offsetTime;segment(i,2)];
        end
    end
    duration=offsetTime-onsetTime;
end
waitbar(0.8,h,sprintf('%d%% Pitch2Note converting...',80));
%Parameter assignment
if ~isempty(onset)
    avgPitch=zeros(length(onset),1);
    for i=1:length(onset)
        avgPitch(i)=median(pitch(logical((time>=onset(i)).*(time<=onset(i)+duration(i)))));%averaging the pitch within a note
    end%mean->median
    %Eliminate NAN and 0 notes
    nan_zero=(avgPitch==0)+(isnan(avgPitch));
    nan_zero=logical(nan_zero>0);
    onset(nan_zero)=[];
    duration(nan_zero)=[];
    avgPitch(nan_zero)=[];
else
    avgPitch=[];
end
waitbar(0.9,h,sprintf('%d%% Pitch2Note converting...',90));
end